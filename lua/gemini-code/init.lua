---@mod gemini-code Gemini Code Neovim Integration
---@brief [[
--- A plugin for seamless integration between Gemini AI assistant and Neovim.
--- This plugin provides a terminal-based interface to Gemini within Neovim.
---
--- Requirements:
--- - Neovim 0.7.0 or later
--- - Gemini CLI tool installed and available in PATH
---
--- Usage:
--- ```lua
--- require('gemini-code').setup({
---   -- Configuration options (optional)
--- })
--- ```
---@brief ]]

-- Import modules
local config = require('gemini-code.config')
local commands = require('gemini-code.commands')
local keymaps = require('gemini-code.keymaps')
local file_refresh = require('gemini-code.file_refresh')
local terminal = require('gemini-code.terminal')
local git = require('gemini-code.git')

local M = {}

-- Store the current configuration
--- @type table
M.config = {}

-- Terminal buffer and window management
--- @type table
M.gemini_code = terminal.terminal

--- Force insert mode when entering the Gemini window
--- This is a public function used in keymaps
function M.force_insert_mode()
  terminal.force_insert_mode(M, M.config)
end

--- Get the current active buffer number
--- @return number|nil bufnr Current Gemini instance buffer number or nil
local function get_current_buffer_number()
  -- Get current instance from the instances table
  local current_instance = M.gemini_code.current_instance
  if current_instance and type(M.gemini_code.instances) == 'table' then
    return M.gemini_code.instances[current_instance]
  end
  return nil
end

--- Toggle the Gemini terminal window
--- This is a public function used by commands
function M.toggle()
  terminal.toggle(M, M.config, git)

  -- Set up terminal navigation keymaps after toggling
  local bufnr = get_current_buffer_number()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    keymaps.setup_terminal_navigation(M, M.config)
  end
end

--- Toggle the Gemini terminal window with a specific command variant
--- @param variant_name string The name of the command variant to use
function M.toggle_with_variant(variant_name)
  if not variant_name or not M.config.command_variants[variant_name] then
    -- If variant doesn't exist, fall back to regular toggle
    return M.toggle()
  end

  -- Store the original command
  local original_command = M.config.command

  -- Set the command with the variant args
  M.config.command = original_command .. ' ' .. M.config.command_variants[variant_name]

  -- Call the toggle function with the modified command
  terminal.toggle(M, M.config, git)

  -- Set up terminal navigation keymaps after toggling
  local bufnr = get_current_buffer_number()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    keymaps.setup_terminal_navigation(M, M.config)
  end

  -- Restore the original command
  M.config.command = original_command
end

--- Setup function for the plugin
--- @param user_config? table User configuration table (optional)
function M.setup(user_config)
  -- Parse and validate configuration
  -- Don't use silent mode for regular usage - users should see config errors
  M.config = config.parse_config(user_config, false)

  -- Set up autoread option
  vim.o.autoread = true

  -- Set up file refresh functionality
  file_refresh.setup(M, M.config)

  -- Register commands
  commands.register_commands(M)

  -- Register keymaps
  keymaps.register_keymaps(M, M.config)

  -- Set up force insert autocmd
  keymaps.setup_force_insert_autocmd(M, M.config)
end

return M

