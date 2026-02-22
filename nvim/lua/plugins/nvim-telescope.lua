local M = {}

local function send_to_qflist_and_select(prompt_bufnr)
  local action_state = require('telescope.actions.state')
  local actions = require('telescope.actions')

  local entry = action_state.get_selected_entry()

  actions.send_to_qflist(prompt_bufnr)
  actions.open_qflist(prompt_bufnr)

  if entry then
    local qflist = vim.fn.getqflist()
    local target_filename = entry.filename or (entry.bufnr and vim.fn.bufname(entry.bufnr))
    local target_lnum = entry.lnum or 1

    local target_abs = target_filename and vim.fn.fnamemodify(target_filename, ':p')

    for i, item in ipairs(qflist) do
      local item_filename = item.filename or vim.fn.bufname(item.bufnr)
      local item_abs = vim.fn.fnamemodify(item_filename, ':p')

      if item_abs == target_abs and item.lnum == target_lnum then
        -- Just move cursor to line i in quickfix window (don't open file)
        vim.api.nvim_win_set_cursor(0, {i, 0})
        return
      end
    end
  end
end

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
          ['<C-q>'] = send_to_qflist_and_select,
          ['<C-p>'] = function(prompt_bufnr)
            local current_picker = action_state.get_current_picker(prompt_bufnr)
            local text = vim.fn.getreg('+'):gsub("\n", "\\n") -- which register depends on clipboard option
            current_picker:set_prompt(text, false)
          end
        },
        n = {
          ['<C-q>'] = send_to_qflist_and_select
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
