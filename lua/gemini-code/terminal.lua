---@mod gemini-code.terminal Terminal management for gemini-code.nvim
---@brief [[
--- This module provides terminal buffer management for gemini-code.nvim.
--- It handles creating, toggling, and managing the terminal window.
---@brief ]]

local M = {}

--- Terminal buffer and window management
--- @type table
M.terminal = {
  instances = {},           -- Key-value store of instance id to buffer number
  saved_updatetime = nil,   -- Original updatetime before Gemini was opened
  current_instance = nil,   -- Current instance identifier
}

--- Get the current instance identifier
--- @param git table The git module
--- @param config table The plugin configuration
--- @return string identifier Instance identifier
local function get_instance_identifier(git, config)
  if config.git.multi_instance then
    if config.git.use_git_root then
      local git_root = git.get_git_root()
      if git_root then
        return git_root
      else
        return vim.fn.getcwd()
      end
    else
      return vim.fn.getcwd()
    end
  else
    -- Use a fixed ID for single instance mode
    return "global"
  end
end

--- Create a split window according to the specified position configuration
--- @param position string Window position configuration
--- @param config table Plugin configuration containing window settings
--- @param existing_bufnr number|nil Buffer number of existing buffer to show in the split (optional)
local function create_split(position, config, existing_bufnr)
  local is_vertical = position:match('vsplit') or position:match('vertical')
  
  -- Create the window with the user's specified command
  if position:match('split') then
    vim.cmd(position)
  else
    vim.cmd(position .. ' split')
  end
  
  -- If we have an existing buffer to display, switch to it
  if existing_bufnr then
    vim.cmd('buffer ' .. existing_bufnr)
  end
  
  -- Resize the window appropriately based on split type
  if is_vertical then
    vim.cmd('vertical resize ' .. math.floor(vim.o.columns * config.window.split_ratio))
  else
    vim.cmd('resize ' .. math.floor(vim.o.lines * config.window.split_ratio))
  end
end

--- Set up function to force insert mode when entering the Gemini window
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
function M.force_insert_mode(gemini_code, config)
  local current_bufnr = vim.fn.bufnr('%')
  
  -- Check if current buffer is any of our Gemini instances
  local is_gemini_instance = false
  for _, bufnr in pairs(gemini_code.gemini_code.instances) do
    if bufnr and bufnr == current_bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      is_gemini_instance = true
      break
    end
  end
  
  if is_gemini_instance then
    -- Only enter insert mode if configured and not in normal mode start
    if config.window.start_in_normal_mode then
      return
    end
    
    local mode = vim.api.nvim_get_mode().mode
    if vim.bo.buftype == 'terminal' and mode ~= 't' and mode ~= 'i' then
      vim.cmd 'silent! stopinsert'
      vim.schedule(function()
        vim.cmd 'silent! startinsert'
      end)
    end
  end
end

--- Toggle the Gemini terminal window
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
--- @param git table The git module
function M.toggle(gemini_code, config, git)
  -- Determine instance ID based on config
  local instance_id = get_instance_identifier(git, config)
  gemini_code.gemini_code.current_instance = instance_id
  
  -- Check if this Gemini instance is already running
  local bufnr = gemini_code.gemini_code.instances[instance_id]
  
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    -- Check if there's a window displaying this Gemini buffer
    local win_ids = vim.fn.win_findbuf(bufnr)
    if #win_ids > 0 then
      -- Gemini is visible, close the window
      for _, win_id in ipairs(win_ids) do
        vim.api.nvim_win_close(win_id, true)
      end
    else
      -- Gemini buffer exists but is not visible, open it in a split
      create_split(config.window.position, config, bufnr)
      
      -- Force insert mode unless configured to start in normal mode
      if not config.window.start_in_normal_mode then
        vim.schedule(function()
          vim.cmd 'stopinsert | startinsert'
        end)
      end
    end
  else
    -- Prune invalid buffer entries
    if bufnr and not vim.api.nvim_buf_is_valid(bufnr) then
      gemini_code.gemini_code.instances[instance_id] = nil
    end
    
    -- This Gemini instance is not running, start it in a new split
    create_split(config.window.position, config)
    
    -- Determine if we should use the git root directory
    local cmd = 'terminal ' .. config.command
    if config.git and config.git.use_git_root then
      local git_root = git.get_git_root()
      if git_root then
        -- Use pushd/popd to change directory
        local separator = config.shell.separator
        local pushd_cmd = config.shell.pushd_cmd
        local popd_cmd = config.shell.popd_cmd
        cmd = 'terminal ' .. pushd_cmd .. ' ' .. vim.fn.shellescape(git_root) .. ' ' .. separator .. ' ' .. config.command .. ' ' .. separator .. ' ' .. popd_cmd
      end
    end
    
    vim.cmd(cmd)
    vim.cmd 'setlocal bufhidden=hide'
    
    -- Create a unique buffer name
    local buffer_name
    if config.git.multi_instance then
      buffer_name = 'gemini-code-' .. instance_id:gsub('[^%w%-_]', '-')
    else
      buffer_name = 'gemini-code'
    end
    vim.cmd('file ' .. buffer_name)
    
    if config.window.hide_numbers then
      vim.cmd 'setlocal nonumber norelativenumber'
    end
    
    if config.window.hide_signcolumn then
      vim.cmd 'setlocal signcolumn=no'
    end
    
    -- Store buffer number for this instance
    gemini_code.gemini_code.instances[instance_id] = vim.fn.bufnr('%')
    
    -- Automatically enter insert mode unless configured to start in normal mode
    if config.window.enter_insert and not config.window.start_in_normal_mode then
      vim.cmd 'startinsert'
    end
  end
end

return M

