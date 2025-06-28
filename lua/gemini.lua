
local M = {}

local config = {
  -- Default configuration
  command = "npx https://github.com/google-gemini/gemini-cli",
  terminal = {
    enabled = true, -- Use floating terminal by default
    position = "bottom",
    height = 15,
    width = 120,
    border = "rounded",
  },
  chat_box = {
    enabled = false, -- Use chat box by default
    position = "right", -- "right" or "left"
    width = 60,
  },
  prompts = {
    default = "",
  },
}

function M.setup(args)
  config = vim.tbl_deep_extend("force", config, args or {})
end

local function get_visual_selection()
  local _, srow, scol = vim.fn.getpos("'<")
  local _, erow, ecol = vim.fn.getpos("'>")
  if srow == 0 or erow == 0 then
    return ""
  end
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
    vim.api.nvim_win_set_cursor(win_id, {1, 0}) -- Move cursor to top of chat box
  else
    print("Error: Neither terminal nor chat_box is enabled in configuration.")
  end
end

function M.prompt(opts)
  local selection = get_visual_selection()
  local input = table.concat(opts.args, " ")
  local prompt = get_prompt_for_filetype()
  M.run("prompt " .. prompt .. " " .. input .. " " .. selection)
end

function M.shell(opts)
  local selection = get_visual_selection()
  local input = table.concat(opts.args, " ")
  M.run("shell " .. input .. " " .. selection)
end

function M.info(opts)
  M.run("info")
}

function M.prompt_with_system_prompt(opts)
  local selection = get_visual_selection()
  local input = table.concat(opts.args, " ")
  M.run("prompt -p \"" .. input .. "\" " .. selection)
end

function M.toggle_verbose(opts)
  M.run("toggle-verbose")
end

return M

