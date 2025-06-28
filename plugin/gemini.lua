-- Main plugin file for gemini-nvim (modernized)
--
-- This plugin provides a terminal-based interface to Gemini AI assistant
-- similar to claude-code.nvim but for Google's Gemini.
--
-- See: https://github.com/google-gemini/gemini-cli

-- Only load the plugin once
if vim.g.loaded_gemini_nvim then
  return
end
vim.g.loaded_gemini_nvim = 1

-- Check Neovim version compatibility
if vim.fn.has('nvim-0.7') == 0 then
  vim.api.nvim_err_writeln('gemini-nvim requires Neovim 0.7 or later')
  return
end

-- Initialize the plugin with default configuration
-- Users can override this by calling require('gemini').setup() or require('gemini-code').setup()
local gemini = require("gemini")
gemini.setup()

-- Legacy commands for backward compatibility
vim.api.nvim_create_user_command("Gemini", function(opts)
  gemini.prompt(opts)
end, {
  nargs = "*",
  range = true,
  desc = "Toggle Gemini terminal (legacy command)",
})

vim.api.nvim_create_user_command("GeminiS", function(opts)
  gemini.shell(opts)
end, {
  nargs = "*",
  range = true,
  desc = "Toggle Gemini terminal for shell commands (legacy)",
})

vim.api.nvim_create_user_command("GeminiI", function(opts)
  gemini.info(opts)
end, {
  nargs = 0,
  desc = "Toggle Gemini terminal for info (legacy)",
})

vim.api.nvim_create_user_command("GeminiP", function(opts)
  gemini.prompt_with_system_prompt(opts)
end, {
  nargs = "*",
  range = true,
  desc = "Toggle Gemini terminal with system prompt (legacy)",
})

vim.api.nvim_create_user_command("GeminiT", function(opts)
  gemini.toggle_verbose(opts)
end, {
  nargs = 0,
  desc = "Toggle Gemini terminal with verbose output",
})

vim.api.nvim_create_user_command("GeminiChat", function()
  gemini.start_chat()
end, {
  nargs = 0,
  desc = "Start Gemini chat mode (legacy - now opens terminal)",
})

-- Note: The new modular commands (GeminiCode, etc.) are registered 
-- automatically by the gemini-code module when setup() is called
