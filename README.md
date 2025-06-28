
# gemini.nvim

A Neovim plugin for interacting with the Gemini CLI.

## Features

- A floating terminal to run the Gemini CLI
- Commands to interact with the Gemini CLI
- Visual selection support
- Filetype-specific prompts

## Installation

Using your favorite plugin manager:

```lua
{
  "your-username/gemini.nvim",
  config = function()
    require("gemini").setup()
  end,
}
```

## Usage

- `:Gemini <prompt>`: Ask Gemini a question
- `:GeminiS <prompt>`: Ask Gemini a shell command
- `:GeminiI`: Get info from Gemini
- `:GeminiP <prompt>`: Ask Gemini a question with a system prompt
- `:GeminiT`: Toggle verbose output

## Configuration

```lua
require("gemini").setup({
  command = "gemini", -- Path to the gemini-cli executable (e.g., "gemini" if installed globally)
  terminal = {
    enabled = false, -- Set to true to enable the floating terminal
    position = "bottom",
    height = 15,
    width = 120,
    border = "rounded",
  },
  chat_box = {
    enabled = true, -- Set to false to disable the chat box
    position = "right", -- "right" or "left"
    width = 60,
  },
  prompts = {
    default = "",
    python = "You are a python expert.",
  },
})
```
