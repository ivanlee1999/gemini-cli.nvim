-- Main plugin file for gemini.nvim
--
-- Authors:
--   - Gemini
--
-- See: https://github.com/google-gemini/gemini-cli

local gemini = require("gemini")

gemini.setup()

vim.api.nvim_create_user_command("Gemini", gemini.prompt, {
  nargs = "*",
  range = true,
  desc = "Ask Gemini a question",
})
