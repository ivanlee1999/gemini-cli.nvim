
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

vim.api.nvim_create_user_command("GeminiS", gemini.shell, {
  nargs = "*",
  range = true,
  desc = "Ask Gemini a shell command",
})

vim.api.nvim_create_user_command("GeminiI", gemini.info, {
  nargs = "*",
  range = true,
  desc = "Get info from Gemini",
})

vim.api.nvim_create_user_command("GeminiP", gemini.prompt_with_system_prompt, {
  nargs = "*",
  range = true,
  desc = "Ask Gemini a question with a system prompt",
})

vim.api.nvim_create_user_command("GeminiT", gemini.toggle_verbose, {
  nargs = "*",
  range = true,
  desc = "Toggle verbose output",
})
