
local M = {}

local config = {
  -- Default configuration
  terminal = {
    position = "bottom",
    height = 15,
    width = 120,
    border = "rounded",
  },
  prompts = {
    default = "",
  },
}

function M.setup(args)
  config = vim.tbl_deep_extend("force", config, args or {})
end

local function get_visual_selection()
  local _, srow, scol = vim.fn.getpos("'<")
  local _, erow, ecol = vim.fn.getpos("'>")
  if srow == 0 or erow == 0 then
    return ""
  end
  local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
  if #lines == 0 then
    return ""
  end
  lines[#lines] = string.sub(lines[#lines], 1, ecol)
  lines[1] = string.sub(lines[1], scol)
  return table.concat(lines, "\n")
end

local function get_prompt_for_filetype()
  local filetype = vim.bo.filetype
  return config.prompts[filetype] or config.prompts.default
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
  local selection = get_visual_selection()
  local input = table.concat(opts.args, " ")
  local prompt = get_prompt_for_filetype()
  M.run("prompt " .. prompt .. " " .. input .. " " .. selection)
end

function M.shell(opts)
  local selection = get_visual_selection()
  local input = table.concat(opts.args, " ")
  M.run("shell " .. input .. " " .. selection)
end

function M.info(opts)
  M.run("info")
end

function M.prompt_with_system_prompt(opts)
  local selection = get_visual_selection()
  local input = table.concat(opts.args, " ")
  M.run("prompt -p \"" .. input .. "\" " .. selection)
end

function M.toggle_verbose(opts)
  M.run("toggle-verbose")
end

return M
