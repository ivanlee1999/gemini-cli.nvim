---@mod gemini-code.file_refresh File change detection for gemini-code.nvim
---@brief [[
--- This module provides file change detection and auto-reload functionality
--- for gemini-code.nvim when Gemini modifies files externally.
---@brief ]]

local M = {}

-- Timer for file change detection
local refresh_timer = nil

--- Set up file refresh functionality
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
function M.setup(gemini_code, config)
  if not config.refresh.enable then
    return
  end
  
  -- Create autocommand group for file refresh
  local group = vim.api.nvim_create_augroup('GeminiCodeFileRefresh', { clear = true })
  
  -- Set up autocommands for when Gemini Code terminal is opened/closed
  vim.api.nvim_create_autocmd('TermOpen', {
    group = group,
    callback = function()
      local bufname = vim.fn.expand('<afile>')
      if bufname:match('gemini%-code') then
        M.start_file_watching(gemini_code, config)
      end
    end,
    desc = 'Start file watching when Gemini Code terminal opens',
  })
  
  vim.api.nvim_create_autocmd('TermClose', {
    group = group,
    callback = function()
      local bufname = vim.fn.expand('<afile>')
      if bufname:match('gemini%-code') then
        M.stop_file_watching(gemini_code, config)
      end
    end,
    desc = 'Stop file watching when Gemini Code terminal closes',
  })
  
  -- Set up autocommand for file changes
  vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
    group = group,
    callback = function()
      if M.is_gemini_active(gemini_code) then
        vim.cmd('checktime')
      end
    end,
    desc = 'Check for file changes when Gemini Code is active',
  })
  
  -- Notification when files are reloaded
  if config.refresh.show_notifications then
    vim.api.nvim_create_autocmd('FileChangedShellPost', {
      group = group,
      callback = function()
        if M.is_gemini_active(gemini_code) then
          local filename = vim.fn.expand('<afile>:t')
          vim.notify('File reloaded: ' .. filename, vim.log.levels.INFO, {
            title = 'Gemini Code',
          })
        end
      end,
      desc = 'Show notification when files are reloaded by Gemini Code',
    })
  end
end

--- Check if Gemini Code is currently active
--- @param gemini_code table The main plugin module
--- @return boolean is_active True if Gemini Code is active
function M.is_gemini_active(gemini_code)
  for _, bufnr in pairs(gemini_code.gemini_code.instances) do
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      local win_ids = vim.fn.win_findbuf(bufnr)
      if #win_ids > 0 then
        return true
      end
    end
  end
  return false
end

--- Start file watching when Gemini Code is active
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
function M.start_file_watching(gemini_code, config)
  -- Save original updatetime if not already saved
  if not gemini_code.gemini_code.saved_updatetime then
    gemini_code.gemini_code.saved_updatetime = vim.o.updatetime
  end
  
  -- Set faster updatetime for better responsiveness
  vim.o.updatetime = config.refresh.updatetime
  
  -- Start timer for periodic file checks
  if refresh_timer then
    refresh_timer:stop()
  end
  
  refresh_timer = vim.loop.new_timer()
  if refresh_timer then
    refresh_timer:start(config.refresh.timer_interval, config.refresh.timer_interval, vim.schedule_wrap(function()
      if M.is_gemini_active(gemini_code) then
        vim.cmd('silent! checktime')
      else
        M.stop_file_watching(gemini_code, config)
      end
    end))
  end
end

--- Stop file watching when Gemini Code is no longer active
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
function M.stop_file_watching(gemini_code, config)
  -- Restore original updatetime
  if gemini_code.gemini_code.saved_updatetime then
    vim.o.updatetime = gemini_code.gemini_code.saved_updatetime
    gemini_code.gemini_code.saved_updatetime = nil
  end
  
  -- Stop timer
  if refresh_timer then
    refresh_timer:stop()
    refresh_timer = nil
  end
end

return M

