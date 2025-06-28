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
  vim.api.nvim_create_user_command('GeminiCode', function()
    gemini_code.toggle()
  end, {
    desc = 'Toggle Gemini Code terminal window',
  })
  
  -- Alternative command names for convenience
  vim.api.nvim_create_user_command('Gemini', function()
    gemini_code.toggle()
  end, {
    desc = 'Toggle Gemini Code terminal window',
  })
  
  -- Command variants - dynamically created based on config
  if gemini_code.config and gemini_code.config.command_variants then
    for variant_name, _ in pairs(gemini_code.config.command_variants) do
      local command_name = 'GeminiCode' .. variant_name:sub(1,1):upper() .. variant_name:sub(2)
      
      vim.api.nvim_create_user_command(command_name, function()
        gemini_code.toggle_with_variant(variant_name)
      end, {
        desc = 'Toggle Gemini Code with ' .. variant_name .. ' variant',
      })
      
      -- Also create shorter version
      local short_command_name = 'Gemini' .. variant_name:sub(1,1):upper() .. variant_name:sub(2)
      vim.api.nvim_create_user_command(short_command_name, function()
        gemini_code.toggle_with_variant(variant_name)
      end, {
        desc = 'Toggle Gemini Code with ' .. variant_name .. ' variant',
      })
    end
  end
  
  -- Version command
  vim.api.nvim_create_user_command('GeminiCodeVersion', function()
    local version = gemini_code.get_version()
    vim.notify('gemini-code.nvim version: ' .. version, vim.log.levels.INFO)
  end, {
    desc = 'Show gemini-code.nvim version',
  })
end

return M

