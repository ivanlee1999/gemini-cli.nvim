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
  desc = "Ask Gemini a question or start chat mode (no args)",
})

vim.api.nvim_create_user_command("GeminiS", gemini.shell, {
  nargs = "*",
  range = true,
  desc = "Ask Gemini for shell commands",
})

vim.api.nvim_create_user_command("GeminiI", gemini.info, {
  nargs = 0,
  desc = "Get info from Gemini",
})

vim.api.nvim_create_user_command("GeminiP", gemini.prompt_with_system_prompt, {
  nargs = "*",
  range = true,
  desc = "Ask Gemini with a custom system prompt",
})

vim.api.nvim_create_user_command("GeminiT", gemini.toggle_verbose, {
  nargs = 0,
  desc = "Toggle verbose output",
})

vim.api.nvim_create_user_command("GeminiChat", gemini.start_chat, {
  nargs = 0,
  desc = "Start Gemini chat mode",
})
