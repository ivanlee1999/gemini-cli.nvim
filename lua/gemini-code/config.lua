---@mod gemini-code.config Configuration management for gemini-code.nvim
---@brief [[
--- This module handles configuration parsing and validation for gemini-code.nvim.
--- It provides default configuration and validates user configuration.
---@brief ]]

local M = {}

--- Default configuration for the plugin
--- @type table
M.default_config = {
  -- Terminal window settings
  window = {
    split_ratio = 0.3,       -- Percentage of screen for the terminal window
    position = "botright vsplit",   -- Position of the window (right side by default)
    enter_insert = true,     -- Whether to enter insert mode when opening Gemini
    hide_numbers = true,     -- Hide line numbers in the terminal window
    hide_signcolumn = true,  -- Hide the sign column in the terminal window
    start_in_normal_mode = false, -- Start in normal mode instead of insert
  },
  -- File refresh settings
  refresh = {
    enable = true,           -- Enable file change detection
    updatetime = 100,        -- updatetime when Gemini is active (milliseconds)
    timer_interval = 1000,   -- How often to check for file changes (milliseconds)
    show_notifications = true, -- Show notification when files are reloaded
  },
  -- Git project settings
  git = {
    use_git_root = true,     -- Set CWD to git root when opening Gemini
    multi_instance = true,   -- Allow multiple instances per git repo
  },
  -- Shell-specific settings
  shell = {
    separator = '&&',        -- Command separator used in shell commands
    pushd_cmd = 'pushd',     -- Command to push directory onto stack
    popd_cmd = 'popd',       -- Command to pop directory from stack
  },
  -- Command settings
  command = "gemini",        -- Command used to launch Gemini
  -- Command variants
  command_variants = {
    -- Common variants
    continue = "--continue", -- Continue previous conversation
    verbose = "--verbose",   -- Enable verbose output
    help = "--help",         -- Show help
  },
  -- Keymaps
  keymaps = {
    toggle = {
      normal = "<C-,>",       -- Normal mode keymap for toggling Gemini
      terminal = "<C-,>",     -- Terminal mode keymap for toggling Gemini
      variants = {
        continue = "<leader>gC", -- Normal mode keymap for Gemini with continue flag
        verbose = "<leader>gV",  -- Normal mode keymap for Gemini with verbose flag
      },
    },
    window_navigation = true, -- Enable window navigation keymaps
    scrolling = true,         -- Enable scrolling keymaps for page up/down
  }
}

--- Validate configuration
--- @param config table Configuration to validate
--- @param silent boolean Whether to suppress error messages
--- @return boolean valid True if configuration is valid
local function validate_config(config, silent)
  if type(config) ~= 'table' then
    if not silent then
      vim.notify('gemini-code.nvim: Configuration must be a table', vim.log.levels.ERROR)
    end
    return false
  end
  
  -- Validate window configuration
  if config.window then
    if config.window.split_ratio and (config.window.split_ratio <= 0 or config.window.split_ratio >= 1) then
      if not silent then
        vim.notify('gemini-code.nvim: window.split_ratio must be between 0 and 1', vim.log.levels.ERROR)
      end
      return false
    end
  end
  
  -- Validate refresh configuration
  if config.refresh then
    if config.refresh.updatetime and config.refresh.updatetime < 1 then
      if not silent then
        vim.notify('gemini-code.nvim: refresh.updatetime must be >= 1', vim.log.levels.ERROR)
      end
      return false
    end
    
    if config.refresh.timer_interval and config.refresh.timer_interval < 100 then
      if not silent then
        vim.notify('gemini-code.nvim: refresh.timer_interval must be >= 100', vim.log.levels.ERROR)
      end
      return false
    end
  end
  
  -- Validate command
  if config.command and type(config.command) ~= 'string' then
    if not silent then
      vim.notify('gemini-code.nvim: command must be a string', vim.log.levels.ERROR)
    end
    return false
  end
  
  return true
end

--- Parse and merge user configuration with defaults
--- @param user_config? table User configuration (optional)
--- @param silent? boolean Whether to suppress error messages (optional, defaults to false)
--- @return table config Merged and validated configuration
function M.parse_config(user_config, silent)
  silent = silent or false
  user_config = user_config or {}
  
  -- Validate user configuration
  if not validate_config(user_config, silent) then
    if not silent then
      vim.notify('gemini-code.nvim: Using default configuration due to validation errors', vim.log.levels.WARN)
    end
    user_config = {}
  end
  
  -- Deep merge user config with defaults
  local config = vim.tbl_deep_extend('force', M.default_config, user_config)
  
  -- Final validation of merged config
  if not validate_config(config, silent) then
    if not silent then
      vim.notify('gemini-code.nvim: Configuration validation failed, using defaults', vim.log.levels.ERROR)
    end
    return M.default_config
  end
  
  return config
end

return M

