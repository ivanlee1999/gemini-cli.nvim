---@mod gemini-code.version Version information for gemini-code.nvim
---@brief [[
--- This module provides version information for gemini-code.nvim.
---@brief ]]

local M = {}

-- Plugin version information
M.version = {
  major = 1,
  minor = 0,
  patch = 0,
  suffix = "",
}

--- Get version string
--- @return string version Version string in format "major.minor.patch"
function M.string()
  local version_str = string.format("%d.%d.%d", M.version.major, M.version.minor, M.version.patch)
  if M.version.suffix and M.version.suffix ~= "" then
    version_str = version_str .. "-" .. M.version.suffix
  end
  return version_str
end

--- Get version table
--- @return table version Version information table
function M.table()
  return vim.deepcopy(M.version)
end

return M

