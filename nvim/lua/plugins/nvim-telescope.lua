local M = {}

function M.setup()
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
  vim.keymap.set('n', '<leader>ag', builtin.live_grep, { desc = 'Telescope live grep' })
  vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

  -- telescope fails to detect some file types, but we can configure it
  vim.filetype.add({
    extension = { slim = 'slim' }
  })

  require('telescope').load_extension('fzf')
  require('telescope').setup {
    defaults = {
      layout_config = {
        prompt_position = 'top',
      },
      sorting_strategy = 'ascending',
      mappings = {
        i = {
          ['<esc>'] = 'close',
          ['<C-j>'] = 'move_selection_next',
          ['<C-k>'] = 'move_selection_previous',
        }
      }
    }
  }
end

return M
