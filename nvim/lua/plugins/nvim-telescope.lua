local M = {}

function M.setup()
  local builtin = require('telescope.builtin')
  local action_state = require("telescope.actions.state")

  -- Keep some telescope-specific mappings for specialized tasks
  vim.keymap.set('n', '<c-p>', builtin.find_files, { desc = 'Telescope find files' })
  vim.keymap.set('n', '<Tab>', builtin.oldfiles, { desc = 'Recent files' })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
  vim.keymap.set('n', '<leader>ag', builtin.live_grep, { desc = 'Telescope live grep' })
  vim.keymap.set('n', '<leader>g', builtin.grep_string, { desc = 'Telescope grep selected text' })
  vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
  
  -- Additional telescope-specific mappings
  vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Telescope LSP references' })
  vim.keymap.set('n', '<leader>fd', builtin.lsp_document_symbols, { desc = 'Telescope document symbols' })
  vim.keymap.set('n', '<leader>fs', builtin.lsp_workspace_symbols, { desc = 'Telescope workspace symbols' })

  -- telescope fails to detect some file types, but we can configure it
  vim.filetype.add({
    extension = { slim = 'slim' }
  })

  require('telescope').setup {
    extensions = {
      fzf = {
        case_mode = 'ignore_case'
      }
    },
    defaults = {
      layout_strategy = 'vertical',
      layout_config = {
        prompt_position = 'top',
        -- mirror = true
      },
      sorting_strategy = 'ascending',
      mappings = {
        i = {
          ['<esc>'] = 'close',
          ['<C-j>'] = 'move_selection_next',
          ['<C-k>'] = 'move_selection_previous',
          ['<C-p>'] = function(prompt_bufnr)
            local current_picker = action_state.get_current_picker(prompt_bufnr)
            local text = vim.fn.getreg('+'):gsub("\n", "\\n") -- which register depends on clipboard option
            current_picker:set_prompt(text, false)
          end
        }
      }
    },
    pickers = {
      oldfiles = {
        only_cwd = true,
        layout_strategy = 'vertical',
        layout_config = {
          prompt_position = 'top',
          -- mirror = true
        }
      }
    }
  }

  require('telescope').load_extension('fzf')
end

return M
