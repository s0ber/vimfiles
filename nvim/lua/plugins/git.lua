local M = {}

function M.setup()
  local actions = require('diffview.actions')

  -- Moving the cursor down the file list opens that file's diff straight away, the way
  -- a preview pane behaves. Diffview's default "j"/"k" only move the cursor and wait
  -- for "<cr>"; these are the same actions its "<tab>"/"<s-tab>" already use.
  local function preview_as_you_move(panel)
    return {
      { 'n', 'q', '<cmd>DiffviewClose<cr>', { desc = 'Close review' } },
      { 'n', 'j', actions.select_next_entry, { desc = 'Open the next ' .. panel } },
      { 'n', '<down>', actions.select_next_entry, { desc = 'Open the next ' .. panel } },
      { 'n', 'k', actions.select_prev_entry, { desc = 'Open the previous ' .. panel } },
      { 'n', '<up>', actions.select_prev_entry, { desc = 'Open the previous ' .. panel } }
    }
  end

  require('diffview').setup({
    enhanced_diff_hl = true,
    view = {
      default = { layout = 'diff2_horizontal', winbar_info = false },
      file_history = { layout = 'diff2_horizontal', winbar_info = true },
      merge_tool = { layout = 'diff3_mixed', disable_diagnostics = true }
    },
    file_panel = {
      -- A flat list of changed files instead of a directory tree ("i" toggles it).
      listing_style = 'list',
      win_config = { position = 'left', width = 40 }
    },
    hooks = {
      -- Diff panes inherit the global "nowrap" from .vimrc. Wrap them so long lines are
      -- readable without scrolling sideways. "breakindent" keeps continuation rows
      -- aligned with the code's indentation, "linebreak" wraps at words, not mid-token.
      diff_buf_win_enter = function(_, winid)
        vim.wo[winid].wrap = true
        vim.wo[winid].linebreak = true
        vim.wo[winid].breakindent = true
      end
    },
    keymaps = {
      -- "q" closes the whole review from anywhere inside it.
      view = { { 'n', 'q', '<cmd>DiffviewClose<cr>', { desc = 'Close review' } } },
      file_panel = preview_as_you_move('file'),
      file_history_panel = preview_as_you_move('commit')
    }
  })

  local function review_toggle()
    if require('diffview.lib').get_current_view() then
      vim.cmd('DiffviewClose')
    else
      vim.cmd('DiffviewOpen')
    end
  end

  -- The commit this branch actually forked from, however far master has moved since.
  local function merge_base()
    local base = vim.fn.systemlist('git merge-base HEAD origin/master')[1]

    if vim.v.shell_error ~= 0 or not base or base == '' then
      return 'master'
    end

    return base
  end

  -- The "-----" filler lines (where one side has nothing to show) are drawn with
  -- DiffDelete, which diffview maps to DiffviewDiffDeleteDim. That links to Comment by
  -- default, which is far too loud. Derive a much darker shade from it instead, so this
  -- keeps working across colorschemes rather than hardcoding a rose-pine hex.
  local function dim_diff_fillers()
    local comment = vim.api.nvim_get_hl(0, { name = 'Comment', link = false })
    local fg = comment.fg or 0x6e6a86
    local amount = 0.22

    local r = math.floor(math.floor(fg / 65536) % 256 * amount)
    local g = math.floor(math.floor(fg / 256) % 256 * amount)
    local b = math.floor(fg % 256 * amount)

    vim.api.nvim_set_hl(0, 'DiffviewDiffDeleteDim', { fg = r * 65536 + g * 256 + b, bg = 'NONE' })
  end

  vim.api.nvim_create_autocmd('ColorScheme', { callback = dim_diff_fillers, desc = 'Dim diffview filler lines' })
  dim_diff_fillers()

  -- Diff panes are kept in step by 'scrollbind', but that only fires when the *current*
  -- window scrolls. A mouse wheel over the other pane scrolls it directly, so the panes
  -- drift apart. For a scrollbound window under the mouse, scroll it via nvim_win_call
  -- instead - that makes it current just long enough for the sync to run. Any other
  -- window gets the default wheel behaviour, untouched.
  local function wheel(key, motion, axis)
    local default = vim.api.nvim_replace_termcodes(key, true, false, true)
    local scroll = vim.api.nvim_replace_termcodes(motion, true, false, true)
    local fallback = axis == 'hor' and 6 or 3 -- vim's own 'mousescroll' defaults

    return function()
      local win = vim.fn.getmousepos().winid

      if win == 0 or not vim.wo[win].scrollbind then
        vim.api.nvim_feedkeys(default, 'n', false)
        return
      end

      local amount = tonumber(vim.o.mousescroll:match(axis .. ':(%d+)')) or fallback
      vim.api.nvim_win_call(win, function() vim.cmd('normal! ' .. amount .. scroll) end)
    end
  end

  local desc = { desc = 'Scroll, keeping diff panes in sync' }
  vim.keymap.set({ 'n', 'x' }, '<ScrollWheelDown>',  wheel('<ScrollWheelDown>',  '<C-e>', 'ver'), desc)
  vim.keymap.set({ 'n', 'x' }, '<ScrollWheelUp>',    wheel('<ScrollWheelUp>',    '<C-y>', 'ver'), desc)
  vim.keymap.set({ 'n', 'x' }, '<ScrollWheelRight>', wheel('<ScrollWheelRight>', 'zl',    'hor'), desc)
  vim.keymap.set({ 'n', 'x' }, '<ScrollWheelLeft>',  wheel('<ScrollWheelLeft>',  'zh',    'hor'), desc)

  vim.keymap.set('n', '<leader>vv', review_toggle,                             { desc = 'Review working tree' })
  vim.keymap.set('n', '<leader>vb', function() vim.cmd('DiffviewOpen ' .. merge_base()) end,
                                                                              { desc = 'Review branch vs master' })
  vim.keymap.set('n', '<leader>vl', '<cmd>DiffviewOpen HEAD~1<cr>',            { desc = 'Review last commit' })
  vim.keymap.set('n', '<leader>vh', '<cmd>DiffviewFileHistory<cr>',            { desc = 'Repo history' })
  vim.keymap.set('n', '<leader>vf', '<cmd>DiffviewFileHistory --follow %<cr>', { desc = 'File history' })
  vim.keymap.set('n', '<leader>vc', function() Snacks.picker.git_log() end,    { desc = 'Recent commits' })
end

return M
