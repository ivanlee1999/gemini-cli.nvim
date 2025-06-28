
# gemini-nvim

A modern Neovim plugin for interacting with Google's Gemini CLI in a terminal-based interface.

## Features

- **Split Terminal Interface**: Opens Gemini in a dedicated terminal split on the right side by default
- **Multiple Commands**: Various command variants (continue, verbose, help) with dedicated keymaps
- **Git Integration**: Automatically uses git root as working directory
- **File Change Detection**: Automatically refreshes files when they change during Gemini sessions
- **Flexible Configuration**: Highly configurable window positioning, keymaps, and behavior
- **Modern Architecture**: Clean, modular codebase with proper documentation

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

### Main Commands
- `:GeminiCode` or `:Gemini`: Toggle the Gemini terminal window
- `:GeminiCodeVersion`: Show plugin version

### Command Variants
- `:GeminiCodeContinue` or `:GeminiContinue`: Toggle Gemini with continue flag
- `:GeminiCodeVerbose` or `:GeminiVerbose`: Toggle Gemini with verbose flag
- `:GeminiCodeHelp` or `:GeminiHelp`: Toggle Gemini with help flag

### Default Keymaps
- `<C-,>`: Toggle Gemini terminal (both normal and terminal mode)
- `<leader>gC`: Toggle Gemini with continue flag
- `<leader>gV`: Toggle Gemini with verbose flag

### Window Navigation
When `window_navigation` is enabled (default):
- `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`: Navigate between windows
- `<C-w>h`, `<C-w>j`, `<C-w>k`, `<C-w>l`: Standard window navigation

### Scrolling
When `scrolling` is enabled (default):
- `<PageUp>`, `<PageDown>`: Scroll in terminal mode

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
  
  -- Command variants
  command_variants = {
    continue = "--continue",              -- Continue previous conversation
    verbose = "--verbose",                -- Enable verbose output
    help = "--help",                      -- Show help
  },
  
  -- Keymaps
  keymaps = {
    toggle = {
      normal = "<C-,>",                   -- Normal mode keymap for toggling Gemini
      terminal = "<C-,>",                 -- Terminal mode keymap for toggling Gemini
      variants = {
        continue = "<leader>gC",          -- Normal mode keymap for Gemini with continue flag
        verbose = "<leader>gV",           -- Normal mode keymap for Gemini with verbose flag
      },
    },
    window_navigation = true,             -- Enable window navigation keymaps
    scrolling = true,                     -- Enable scrolling keymaps for page up/down
  }
})
```
