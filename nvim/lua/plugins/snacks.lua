local M = {}

function M.setup()
  require('snacks').setup({
    input = {},
    picker = {},
    terminal = {}
  })
  vim.keymap.set('n', '<leader>t', Snacks.terminal.toggle, { desc = 'Toggle Snacks terminal' })

end

return M

