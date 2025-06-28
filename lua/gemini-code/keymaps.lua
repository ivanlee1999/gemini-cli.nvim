---@mod gemini-code.keymaps Keymap management for gemini-code.nvim
---@brief [[
--- This module handles keymap registration for gemini-code.nvim.
--- It provides keymaps for toggling and navigating Gemini Code.
---@brief ]]

local M = {}

--- Register keymaps for the plugin
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
function M.register_keymaps(gemini_code, config)
  local keymaps = config.keymaps
  
  -- Main toggle keymaps
  if keymaps.toggle.normal and keymaps.toggle.normal ~= false then
    vim.keymap.set('n', keymaps.toggle.normal, function()
      gemini_code.toggle()
    end, { desc = 'Toggle Gemini Code', silent = true })
  end
  
  if keymaps.toggle.terminal and keymaps.toggle.terminal ~= false then
    vim.keymap.set('t', keymaps.toggle.terminal, function()
      gemini_code.toggle()
    end, { desc = 'Toggle Gemini Code', silent = true })
  end
  
  -- Variant keymaps
  if keymaps.toggle.variants then
    for variant_name, keymap in pairs(keymaps.toggle.variants) do
      if keymap and keymap ~= false then
        vim.keymap.set('n', keymap, function()
          gemini_code.toggle_with_variant(variant_name)
        end, { desc = 'Toggle Gemini Code (' .. variant_name .. ')', silent = true })
      end
    end
  end
  
  -- Additional convenience keymap
  vim.keymap.set('n', '<leader>ac', function()
    gemini_code.toggle()
  end, { desc = 'Toggle Gemini Code', silent = true })
end

--- Set up terminal navigation keymaps
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
function M.setup_terminal_navigation(gemini_code, config)
  if not config.keymaps.window_navigation then
    return
  end
  
  local current_bufnr = vim.fn.bufnr('%')
  
  -- Check if current buffer is a Gemini instance
  local is_gemini_instance = false
  for _, bufnr in pairs(gemini_code.gemini_code.instances) do
    if bufnr and bufnr == current_bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      is_gemini_instance = true
      break
    end
  end
  
  if not is_gemini_instance then
    return
  end
  
  -- Window navigation keymaps (only for terminal buffers)
  if vim.bo.buftype == 'terminal' then
    local nav_opts = { buffer = current_bufnr, silent = true }
    
    vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', nav_opts)
    vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', nav_opts)
    vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', nav_opts)
    vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', nav_opts)
    
    -- Scrolling keymaps if enabled
    if config.keymaps.scrolling then
      vim.keymap.set('t', '<C-f>', '<C-\\><C-n><C-f>', nav_opts)
      vim.keymap.set('t', '<C-b>', '<C-\\><C-n><C-b>', nav_opts)
    end
  end
end

--- Set up autocommands for force insert mode
--- @param gemini_code table The main plugin module
--- @param config table The plugin configuration
function M.setup_force_insert_autocmd(gemini_code, config)
  if not config.window.enter_insert or config.window.start_in_normal_mode then
    return
  end
  
  -- Create autocommand group
  local group = vim.api.nvim_create_augroup('GeminiCodeForceInsert', { clear = true })
  
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function()
      gemini_code.force_insert_mode()
    end,
    desc = 'Force insert mode when entering Gemini Code buffer',
  })
end

return M

