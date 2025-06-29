
# gemini.nvim

A Neovim plugin for interacting with Google's Gemini CLI.

## Installation

Using your favorite plugin manager:

### lazy.nvim
```lua
{
  "ivanlee1999/gemini-nvim",
  config = function()
    require("gemini-code").setup()
  end,
}
```

### packer.nvim
```lua
use {
  "ivanlee1999/gemini-nvim",
  config = function()
    require("gemini-code").setup()
  end,
}
```

### vim-plug
```vim
Plug 'ivanlee1999/gemini-nvim'
" Add this to your init.lua or init.vim:
lua require("gemini-code").setup()
```

## Usage

- `:Gemini`: Toggle the Gemini terminal window.
- `:GeminiContinue`: Continue the conversation in the Gemini terminal.

## Configuration

```lua
require("gemini-code").setup({
  -- Command to launch Gemini CLI
  command = "gemini",
  
  -- Terminal window settings
  window = {
    split_ratio = 0.3,                    -- Percentage of screen for the terminal window
    position = "botright vsplit",         -- Position of the window (right side by default)
    enter_insert = true,                  -- Whether to enter insert mode when opening Gemini
    hide_numbers = true,                  -- Hide line numbers in the terminal window
    hide_signcolumn = true,               -- Hide the sign column in the terminal window
    start_in_normal_mode = false,         -- Start in normal mode instead of insert
  },
  
  -- File refresh settings
  refresh = {
    enable = true,                        -- Enable file change detection
    updatetime = 100,                     -- updatetime when Gemini is active (milliseconds)
    timer_interval = 1000,                -- How often to check for file changes (milliseconds)
    show_notifications = true,            -- Show notification when files are reloaded
  },
  
  -- Git project settings
  git = {
    use_git_root = true,                  -- Set CWD to git root when opening Gemini
    multi_instance = true,                -- Allow multiple instances per git repo
  },
  
  -- Shell-specific settings
  shell = {
    separator = '&&',                     -- Command separator used in shell commands
    pushd_cmd = 'pushd',                  -- Command to push directory onto stack
    popd_cmd = 'popd',                    -- Command to pop directory from stack
  },
  
})
```
