---@mod gemini-code.commands Command registration for gemini-code.nvim
---@brief [[
--- This module handles command registration for gemini-code.nvim.
--- It provides user commands for interacting with Gemini.
---@brief ]]

local M = {}

--- Register user commands for the plugin
--- @param gemini_code table The main plugin module
function M.register_commands(gemini_code)
  -- Main toggle command
  vim.api.nvim_create_user_command('Gemini', function()
    gemini_code.toggle()
  end, {
    desc = 'Toggle Gemini terminal window',
  })

  -- Continue command
  vim.api.nvim_create_user_command('GeminiContinue', function()
    gemini_code.toggle_with_variant('continue')
  end, {
    desc = 'Continue the conversation in the Gemini terminal',
  })
end

return M

