---@mod gemini Gemini Neovim Integration (Legacy)
---@brief [[
--- Legacy wrapper for gemini-code.nvim to maintain backward compatibility.
--- This module forwards all calls to the new modular gemini-code implementation.
---@brief ]]

-- Import the new modular implementation
local gemini_code = require('gemini-code')

local M = {}

--- Legacy setup function that maps old config to new config
--- @param args? table Legacy configuration
function M.setup(args)
  args = args or {}
  
  -- Map legacy configuration to new structure
  local new_config = {
    command = args.command or "gemini",
    window = {
      split_ratio = 0.3,
      position = "botright vsplit",
      enter_insert = true,
      hide_numbers = true,
      hide_signcolumn = true,
    },
    refresh = {
      enable = true,
      updatetime = 100,
      timer_interval = 1000,
      show_notifications = true,
    },
    git = {
      use_git_root = true,
      multi_instance = true,
    },
    shell = {
      separator = '&&',
      pushd_cmd = 'pushd',
      popd_cmd = 'popd',
    },
    command_variants = {
      continue = "--continue",
      verbose = "--verbose",
      help = "--help",
    },
    keymaps = {
      toggle = {
        normal = "<C-,>",
        terminal = "<C-,>",
        variants = {
          continue = "<leader>gC",
          verbose = "<leader>gV",
        },
      },
      window_navigation = true,
      scrolling = true,
    }
  }
  
  -- Handle legacy terminal/chat_box configuration
  if args.terminal and args.terminal.enabled then
    new_config.window.position = args.terminal.position or "botright"
    new_config.window.split_ratio = (args.terminal.height or 15) / vim.o.lines
  end
  
  if args.chat_box and args.chat_box.enabled then
    if args.chat_box.position == "right" then
      new_config.window.position = "botright vsplit"
    elseif args.chat_box.position == "left" then
      new_config.window.position = "topleft vsplit"
    end
    new_config.window.split_ratio = (args.chat_box.width or 30) / 100
  end
  
  -- Handle legacy prompts (convert to command variants)
  if args.prompts then
    -- Legacy prompts are not directly supported in the new terminal-based approach
    -- They would need to be handled by the gemini CLI itself
  end
  
  -- Forward to new implementation
  gemini_code.setup(new_config)
  
  -- Store reference for legacy function calls
  M._gemini_code = gemini_code
end

--- Legacy wrapper functions for backward compatibility
--- These functions now forward to the new gemini-code implementation

--- Toggle the Gemini terminal (legacy function name)
function M.toggle()
  if M._gemini_code then
    M._gemini_code.toggle()
  end
end

--- Start interactive chat mode (maps to toggle in new implementation)
function M.start_chat()
  if M._gemini_code then
    M._gemini_code.toggle()
  end
end

--- Prompt function (maps to toggle in new implementation)
function M.prompt(opts)
  if M._gemini_code then
    M._gemini_code.toggle()
  end
end

--- Shell command (maps to toggle with shell variant)
function M.shell(opts)
  if M._gemini_code then
    M._gemini_code.toggle()
  end
end

--- Info command
function M.info(opts)
  if M._gemini_code then
    M._gemini_code.toggle()
  end
end

--- Prompt with system prompt
function M.prompt_with_system_prompt(opts)
  if M._gemini_code then
    M._gemini_code.toggle()
  end
end

--- Toggle verbose
function M.toggle_verbose(opts)
  if M._gemini_code then
    M._gemini_code.toggle_with_variant('verbose')
  end
end

return M

