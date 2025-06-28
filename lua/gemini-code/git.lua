---@mod gemini-code.git Git operations for gemini-code.nvim
---@brief [[
--- This module provides git-related functionality for gemini-code.nvim.
--- It handles git root detection and repository operations.
---@brief ]]

local M = {}

--- Get the git root directory for the current buffer
--- @return string|nil git_root Git root path or nil if not in a git repository
function M.get_git_root()
  local current_file = vim.fn.expand('%:p')
  local current_dir
  
  -- If we have a current file, start from its directory
  if current_file and current_file ~= '' then
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  else
    -- Otherwise, start from current working directory
    current_dir = vim.fn.getcwd()
  end
  
  -- Walk up the directory tree looking for .git
  local git_root = vim.fn.finddir('.git', current_dir .. ';')
  
  if git_root and git_root ~= '' then
    -- Return the parent directory of .git
    return vim.fn.fnamemodify(git_root, ':h')
  end
  
  return nil
end

--- Check if the current directory is within a git repository
--- @return boolean is_git_repo True if in a git repository
function M.is_git_repo()
  return M.get_git_root() ~= nil
end

--- Get the current git branch name
--- @return string|nil branch_name Current branch name or nil if not in a git repository
function M.get_current_branch()
  local git_root = M.get_git_root()
  if not git_root then
    return nil
  end
  
  -- Try to read branch from .git/HEAD
  local head_file = git_root .. '/.git/HEAD'
  local head_content = vim.fn.readfile(head_file)
  
  if #head_content > 0 then
    local head = head_content[1]
    -- If it's a reference, extract branch name
    local branch = head:match('ref: refs/heads/(.+)')
    if branch then
      return branch
    end
    -- If it's a commit hash, return truncated hash
    if head:match('^%x+$') and #head >= 7 then
      return head:sub(1, 7)
    end
  end
  
  return nil
end

--- Get git repository information
--- @return table|nil repo_info Repository information or nil if not in a git repository
function M.get_repo_info()
  local git_root = M.get_git_root()
  if not git_root then
    return nil
  end
  
  return {
    root = git_root,
    branch = M.get_current_branch(),
    name = vim.fn.fnamemodify(git_root, ':t'),
  }
end

return M

