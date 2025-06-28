
local M = {}

local config = {
  -- Default configuration
  command = "gemini", -- Use globally installed gemini-cli
  terminal = {
    enabled = false, -- Use floating terminal by default
    position = "bottom",
    height = 15,
    width = 120,
    border = "rounded",
  },
  chat_box = {
    enabled = true, -- Use chat box by default
    position = "right", -- "right" or "left"
    width = 60,
    height = 30,
  },
  prompts = {
    default = "",
  },
}

-- Chat state
local chat_state = {
  buf = nil,
  win = nil,
  input_buf = nil,
  input_win = nil,
  is_active = false,
  chat_history = {},
}

function M.setup(args)
  config = vim.tbl_deep_extend("force", config, args or {})

  -- Ensure only one display mode is enabled
  if config.chat_box.enabled and config.terminal.enabled then
    config.terminal.enabled = false
    print("Warning: Both chat_box and terminal are enabled. Prioritizing chat_box.")
  elseif not config.chat_box.enabled and not config.terminal.enabled then
    config.chat_box.enabled = true -- Default to chat_box if neither is enabled
    print("Warning: Neither chat_box nor terminal is enabled. Defaulting to chat_box.")
  end
end

local function get_visual_selection()
  local pos_start = vim.fn.getpos("'<")
  local pos_end = vim.fn.getpos("'>")

  -- Check if marks are set (i.e., visual selection exists)
  if pos_start[2] == 0 or pos_end[2] == 0 then
    return ""
  end

  local srow = pos_start[2]
  local scol = pos_start[3]
  local erow = pos_end[2]
  local ecol = pos_end[3]

  local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
  if #lines == 0 then
    return ""
  end
  lines[#lines] = string.sub(lines[#lines], 1, ecol)
  lines[1] = string.sub(lines[1], scol)
  return table.concat(lines, "\n")
end

local function get_prompt_for_filetype()
  local filetype = vim.bo.filetype
  return config.prompts[filetype] or config.prompts.default
end

function M.run(command)
  local cmd = config.command .. " " .. command

  if config.terminal.enabled then
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = config.terminal.width,
      height = config.terminal.height,
      col = (vim.o.columns - config.terminal.width) / 2,
      row = (vim.o.lines - config.terminal.height) / 2,
      style = "minimal",
      border = config.terminal.border,
    })

    vim.fn.termopen(cmd, {
      on_exit = function()
        vim.api.nvim_win_close(win, true)
      end,
    })
  elseif config.chat_box.enabled then
    local output = vim.fn.systemlist(cmd)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    vim.api.nvim_buf_set_option(buf, "readonly", true)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    -- Temporarily make buffer modifiable to write content
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown") -- or a more appropriate filetype

    local win_id
    if config.chat_box.position == "right" then
      vim.cmd("vsplit")
      vim.cmd(config.chat_box.width .. "wincmd |")
      win_id = vim.api.nvim_get_current_win()
    elseif config.chat_box.position == "left" then
      vim.cmd("vsplit")
      vim.cmd("wincmd h")
      vim.cmd(config.chat_box.width .. "wincmd |")
      win_id = vim.api.nvim_get_current_win()
    end

    vim.api.nvim_win_set_buf(win_id, buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "readonly", true)
    vim.api.nvim_win_set_cursor(win_id, {1, 0}) -- Move cursor to top of chat box
  else
    print("Error: Neither terminal nor chat_box is enabled in configuration.")
  end
end

function M.shell(opts)
  local selection = get_visual_selection()
  local input = type(opts.args) == "table" and table.concat(opts.args, " ") or ""
  M.run("shell " .. input .. " " .. selection)
end

function M.info(opts)
  M.run("info")
end

function M.prompt_with_system_prompt(opts)
  local selection = get_visual_selection()
  local system_prompt = type(opts.args) == "table" and table.concat(opts.args, " ") or ""
  M.run("prompt -p \"" .. system_prompt .. "\" " .. selection)
end

function M.toggle_verbose(opts)
  M.run("toggle-verbose")
end

-- Create chat window layout
local function create_chat_window()
  if chat_state.is_active then
    return
  end

  -- Create main chat buffer for conversation history
  chat_state.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(chat_state.buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(chat_state.buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(chat_state.buf, "swapfile", false)
  vim.api.nvim_buf_set_option(chat_state.buf, "filetype", "markdown")

  -- Create input buffer for user input
  chat_state.input_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(chat_state.input_buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(chat_state.input_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(chat_state.input_buf, "swapfile", false)

  -- Calculate window dimensions
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local chat_height = math.floor(height * 0.85)
  local input_height = height - chat_height - 1

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Create chat window (main conversation area)
  chat_state.win = vim.api.nvim_open_win(chat_state.buf, true, {
    relative = "editor",
    width = width,
    height = chat_height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " Gemini Chat ",
    title_pos = "center",
  })

  -- Create input window (user input area)
  chat_state.input_win = vim.api.nvim_open_win(chat_state.input_buf, false, {
    relative = "editor",
    width = width,
    height = input_height,
    col = col,
    row = row + chat_height + 1,
    style = "minimal",
    border = "rounded",
    title = " Your Message (Press Enter to send, Ctrl+C to exit) ",
    title_pos = "center",
  })

  -- Set up initial content
  vim.api.nvim_buf_set_option(chat_state.buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(chat_state.buf, 0, -1, false, {
    "# 🤖 Gemini Chat Session",
    "",
    "Welcome to Gemini chat! Type your questions below and press Enter to send.",
    "Press Ctrl+C to exit the chat.",
    "",
    "---",
    ""
  })
  vim.api.nvim_buf_set_option(chat_state.buf, "modifiable", false)

  chat_state.is_active = true
  
  -- Focus on input window
  vim.api.nvim_set_current_win(chat_state.input_win)
  
  -- Set up keymaps for the chat
  setup_chat_keymaps()
end

-- Add message to chat history
local function add_message_to_chat(role, message)
  if not chat_state.buf or not vim.api.nvim_buf_is_valid(chat_state.buf) then
    return
  end

  vim.api.nvim_buf_set_option(chat_state.buf, "modifiable", true)
  
  local lines = vim.api.nvim_buf_get_lines(chat_state.buf, 0, -1, false)
  local new_lines = {}
  
  -- Add role header
  if role == "user" then
    table.insert(new_lines, "")
    table.insert(new_lines, "**You:** " .. message)
    table.insert(new_lines, "")
  else
    table.insert(new_lines, "**Gemini:**")
    table.insert(new_lines, "")
    -- Split message into lines for better formatting
    for line in message:gmatch("[^\r\n]+") do
      table.insert(new_lines, line)
    end
    table.insert(new_lines, "")
    table.insert(new_lines, "---")
    table.insert(new_lines, "")
  end
  
  -- Append new lines to buffer
  vim.api.nvim_buf_set_lines(chat_state.buf, #lines, #lines, false, new_lines)
  vim.api.nvim_buf_set_option(chat_state.buf, "modifiable", false)
  
  -- Scroll to bottom
  local total_lines = vim.api.nvim_buf_line_count(chat_state.buf)
  if vim.api.nvim_win_is_valid(chat_state.win) then
    vim.api.nvim_win_set_cursor(chat_state.win, {total_lines, 0})
  end
end

-- Send user message to Gemini
local function send_message()
  if not chat_state.input_buf or not vim.api.nvim_buf_is_valid(chat_state.input_buf) then
    return
  end
  
  local lines = vim.api.nvim_buf_get_lines(chat_state.input_buf, 0, -1, false)
  local message = table.concat(lines, "\n"):gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
  
  if message == "" then
    return
  end
  
  -- Add user message to chat
  add_message_to_chat("user", message)
  
  -- Clear input buffer
  vim.api.nvim_buf_set_lines(chat_state.input_buf, 0, -1, false, {""})
  
  -- Get response from Gemini
  local cmd = config.command .. ' "' .. message:gsub('"', '\\"') .. '"'
  
  -- Show loading message
  add_message_to_chat("gemini", "🤔 Thinking...")
  
  -- Run command asynchronously
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 then
        -- Remove the loading message by getting all lines and removing the last few
        if vim.api.nvim_buf_is_valid(chat_state.buf) then
          vim.api.nvim_buf_set_option(chat_state.buf, "modifiable", true)
          local all_lines = vim.api.nvim_buf_get_lines(chat_state.buf, 0, -1, false)
          -- Remove the last few lines that contain the loading message
          local new_line_count = #all_lines - 4 -- Remove "**Gemini:**", "", "🤔 Thinking...", ""
          if new_line_count >= 0 then
            vim.api.nvim_buf_set_lines(chat_state.buf, new_line_count, -1, false, {})
          end
          vim.api.nvim_buf_set_option(chat_state.buf, "modifiable", false)
        end
        
        -- Join the response and add it to chat
        local response = table.concat(data, "\n"):gsub("^%s*(.-)%s*$", "%1")
        if response ~= "" then
          add_message_to_chat("gemini", response)
        end
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        local error_msg = table.concat(data, "\n")
        add_message_to_chat("gemini", "❌ Error: " .. error_msg)
      end
    end,
  })
end

-- Close chat window
local function close_chat()
  chat_state.is_active = false
  
  if chat_state.win and vim.api.nvim_win_is_valid(chat_state.win) then
    vim.api.nvim_win_close(chat_state.win, true)
  end
  
  if chat_state.input_win and vim.api.nvim_win_is_valid(chat_state.input_win) then
    vim.api.nvim_win_close(chat_state.input_win, true)
  end
  
  chat_state.buf = nil
  chat_state.win = nil
  chat_state.input_buf = nil
  chat_state.input_win = nil
  chat_state.chat_history = {}
end

-- Set up keymaps for chat interaction
function setup_chat_keymaps()
  -- Enter to send message
  vim.api.nvim_buf_set_keymap(chat_state.input_buf, "i", "<CR>", "", {
    callback = function()
      send_message()
    end,
    noremap = true,
    silent = true,
  })
  
  vim.api.nvim_buf_set_keymap(chat_state.input_buf, "n", "<CR>", "", {
    callback = function()
      send_message()
    end,
    noremap = true,
    silent = true,
  })
  
  -- Ctrl+C to close chat
  vim.api.nvim_buf_set_keymap(chat_state.input_buf, "i", "<C-c>", "", {
    callback = function()
      close_chat()
    end,
    noremap = true,
    silent = true,
  })
  
  vim.api.nvim_buf_set_keymap(chat_state.input_buf, "n", "<C-c>", "", {
    callback = function()
      close_chat()
    end,
    noremap = true,
    silent = true,
  })
  
  -- Also allow closing with 'q' in normal mode
  vim.api.nvim_buf_set_keymap(chat_state.input_buf, "n", "q", "", {
    callback = function()
      close_chat()
    end,
    noremap = true,
    silent = true,
  })
  
  -- Set up similar keymaps for the main chat buffer
  vim.api.nvim_buf_set_keymap(chat_state.buf, "n", "<C-c>", "", {
    callback = function()
      close_chat()
    end,
    noremap = true,
    silent = true,
  })
  
  vim.api.nvim_buf_set_keymap(chat_state.buf, "n", "q", "", {
    callback = function()
      close_chat()
    end,
    noremap = true,
    silent = true,
  })
  
  -- Focus switch between windows
  vim.api.nvim_buf_set_keymap(chat_state.buf, "n", "<Tab>", "", {
    callback = function()
      if chat_state.input_win and vim.api.nvim_win_is_valid(chat_state.input_win) then
        vim.api.nvim_set_current_win(chat_state.input_win)
      end
    end,
    noremap = true,
    silent = true,
  })
  
  vim.api.nvim_buf_set_keymap(chat_state.input_buf, "n", "<Tab>", "", {
    callback = function()
      if chat_state.win and vim.api.nvim_win_is_valid(chat_state.win) then
        vim.api.nvim_set_current_win(chat_state.win)
      end
    end,
    noremap = true,
    silent = true,
  })
end

-- Start interactive chat mode
function M.start_chat()
  if chat_state.is_active then
    print("Chat is already active!")
    return
  end
  
  create_chat_window()
end

-- Modified prompt function to handle chatbox mode
function M.prompt(opts)
  -- If no arguments provided, start chat mode
  if not opts.args or opts.args == "" then
    M.start_chat()
    return
  end
  
  -- Otherwise, use the original prompt functionality
  local selection = get_visual_selection()
  local input = type(opts.args) == "table" and table.concat(opts.args, " ") or opts.args or ""
  local prompt = get_prompt_for_filetype()
  M.run("--prompt \"" .. prompt .. "\" " .. input .. " " .. selection)
end

return M

