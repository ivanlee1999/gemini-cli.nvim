
local M = {}

local config = {
  -- Default configuration
  terminal = {
    position = "bottom",
    height = 15,
    width = 120,
    border = "rounded",
  },
}

function M.setup(args)
  config = vim.tbl_deep_extend("force", config, args or {})
end

function M.run(command)
  local cmd = "npx https://github.com/google-gemini/gemini-cli " .. command
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = config.terminal.width,
    height = config.terminal.height,
    col = (vim.o.columns - config.terminal.width) / 2,
    row = (vim.o.lines - config.terminal.height) / 2,
    style = "minimal",
    border = config.terminal.border,
  })

  vim.fn.termopen(cmd, {
    on_exit = function()
      vim.api.nvim_win_close(win, true)
    end,
  })
end

function M.prompt(opts)
  local input = table.concat(opts.args, " ")
  M.run("prompt " .. input)
end

return M
