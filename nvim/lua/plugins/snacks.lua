local M = {}

function M.setup()
  require('snacks').setup({
    input = {},
    picker = {},
    terminal = {}
  })
  vim.keymap.set('n', '<leader>t', Snacks.terminal.toggle, { desc = 'Toggle Snacks terminal' })

  -- auto-pairs (2019) reads maparg('<CR>')['rhs'] on BufEnter and errors on the Lua
  -- callback mappings a snacks picker installs. It skips any buffer that already has
  -- b:autopairs_loaded, and there is nothing to pair in a picker anyway.
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'snacks_picker_input', 'snacks_picker_list', 'snacks_picker_preview', 'snacks_input', 'snacks_terminal' },
    callback = function(event)
      vim.b[event.buf].autopairs_loaded = 1
    end,
    desc = 'Keep auto-pairs out of snacks buffers'
  })

end

return M

