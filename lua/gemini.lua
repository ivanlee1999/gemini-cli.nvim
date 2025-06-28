
local M = {}

local config = {
  -- Default configuration
}

function M.setup(args)
  config = vim.tbl_deep_extend("force", config, args or {})
end

function M.run(command)
  local cmd = "npx https://github.com/google-gemini/gemini-cli " .. command
  -- We will use a floating terminal to run the command
  -- For now, let's just print the command
  print("Running command: " .. cmd)
end

function M.prompt(opts)
  local input = table.concat(opts.args, " ")
  M.run("prompt " .. input)
end

return M
