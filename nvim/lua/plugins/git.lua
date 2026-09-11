local M = {}

-- What each pane shows in its gutter for a line in a given diff state. Vim marks lines that
-- exist on one side only as DiffAdd in *that* buffer, so on the old side ("a") such a line
-- is a removal, on the new side ("b") an addition. Changed lines are "~" on both.
local line_markers = {
  DiffAdd    = { a = '%#DiffviewGutterRemove#-%*', b = '%#DiffviewGutterAdd#+%*' },
  DiffChange = { a = '%#DiffviewGutterChange#~%*', b = '%#DiffviewGutterChange#~%*' },
  DiffText   = { a = '%#DiffviewGutterChange#~%*', b = '%#DiffviewGutterChange#~%*' }
}

-- Gutter for diff panes: line number, then "+" / "-" / "~" for the line's diff state.
-- Filler rows (the dashes) get nothing.
function M.diff_status_column(side)
  if vim.v.virtnum ~= 0 then
    return '%C'
  end

  local id = vim.fn.diff_hlID(vim.v.lnum, 1)
  local state = id > 0 and vim.fn.synIDattr(id, 'name') or ''
  local marker = line_markers[state] and line_markers[state][side] or ' '

  return '%C%=%l ' .. marker .. ' '
end

function M.setup()
  local actions = require('diffview.actions')

  -- "linematch" re-aligns the lines inside a hunk so that a line with no counterpart is
  -- marked as added/removed instead of being paired positionally and called "changed".
  -- Neovim's default 'diffopt' already names it, but the diff engine only honours it once
  -- the option is set explicitly - so set it, with a higher hunk-size limit than the default.
  vim.opt.diffopt:remove('linematch:40')
  vim.opt.diffopt:append('linematch:120')

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
      -- No wrapping here on purpose: vim aligns diff panes by logical line, so a wrapped
      -- line on one side pushes everything below it out of step with the other.
      diff_buf_win_enter = function(_, winid, ctx)
        vim.wo[winid].statuscolumn =
          "%{%v:lua.require'plugins.git'.diff_status_column('" .. ctx.symbol .. "')%}"
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

  -- Multiply each RGB channel of a 24-bit colour, e.g. 0.25 gives a dark tint of it.
  local function scale(color, amount)
    local r = math.floor(math.floor(color / 65536) % 256 * amount)
    local g = math.floor(math.floor(color / 256) % 256 * amount)
    local b = math.floor(color % 256 * amount)

    return r * 65536 + g * 256 + b
  end

  -- Accents for the three kinds of change. Rose-pine's own "changed" background is
  -- almost the same magenta as its "removed" one, so the changed colour is replaced
  -- with an amber that cannot be mistaken for a removal.
  local accent = { add = 0x9ccfd8, remove = 0xeb6f92, change = 0xf6c177 }

  local function tune_diff_colors()
    -- Filler lines (the dashes where one side has nothing) are drawn with DiffDelete,
    -- which diffview maps to DiffviewDiffDeleteDim. It links to Comment by default,
    -- far too loud - use a much darker shade of it instead.
    local comment = vim.api.nvim_get_hl(0, { name = 'Comment', link = false })
    vim.api.nvim_set_hl(0, 'DiffviewDiffDeleteDim', { fg = scale(comment.fg or 0x6e6a86, 0.22), bg = 'NONE' })

    -- Changed lines: amber tint for the line, stronger amber for the changed text in it.
    vim.api.nvim_set_hl(0, 'DiffviewDiffChange', { bg = scale(accent.change, 0.26) })
    vim.api.nvim_set_hl(0, 'DiffviewDiffText',   { bg = scale(accent.change, 0.42) })

    -- Gutter markers, as coloured glyphs (the diff* groups themes define often only carry
    -- a background, which would paint a block behind the glyph instead).
    vim.api.nvim_set_hl(0, 'DiffviewGutterAdd',    { fg = accent.add,    bold = true })
    vim.api.nvim_set_hl(0, 'DiffviewGutterRemove', { fg = accent.remove, bold = true })
    vim.api.nvim_set_hl(0, 'DiffviewGutterChange', { fg = accent.change, bold = true })
  end

  vim.api.nvim_create_autocmd('ColorScheme', { callback = tune_diff_colors, desc = 'Diffview colours' })
  tune_diff_colors()

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
