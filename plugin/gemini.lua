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


-- Note: The new modular commands (GeminiCode, etc.) are registered
-- automatically by the gemini-code module when setup() is called
