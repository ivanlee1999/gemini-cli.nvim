---@mod gemini-code.keymaps Keymap management for gemini-code.nvim
---@brief [[
--- This module handles keymap registration for gemini-code.nvim.
--- Currently disabled - no keymaps are registered.
---@brief ]]

local M = {}

--- Register keymaps for the plugin (disabled)
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
function M.register_keymaps(gemini_code, config)
  -- Keymaps are disabled
end

--- Set up terminal navigation keymaps (disabled)
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
function M.setup_terminal_navigation(gemini_code, config)
  -- Terminal navigation is disabled
end

--- Set up autocommands for force insert mode
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
function M.setup_force_insert_autocmd(gemini_code, config)
  if not config.window.enter_insert or config.window.start_in_normal_mode then
    return
  end
  
  -- Create autocommand group
  local group = vim.api.nvim_create_augroup('GeminiCodeForceInsert', { clear = true })
  
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function()
      gemini_code.force_insert_mode()
    end,
    desc = 'Force insert mode when entering Gemini Code buffer',
  })
end

return M

