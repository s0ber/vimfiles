local M = {}

-- Multiply each RGB channel of a 24-bit colour, e.g. 0.25 gives a dark tint of it.
local function scale(color, amount)
  local r = math.floor(math.floor(color / 65536) % 256 * amount)
  local g = math.floor(math.floor(color / 256) % 256 * amount)
  local b = math.floor(color % 256 * amount)

  return r * 65536 + g * 256 + b
end

-- Rose-pine moon accents: foam, love, gold. Three hues that cannot be confused for
-- one another, unlike the theme's own diff backgrounds.
local accent = { add = 0x9ccfd8, delete = 0xeb6f92, change = 0xf6c177 }

local function define_highlights()
  vim.api.nvim_set_hl(0, 'UnifiedAdd',    { bg = scale(accent.add,    0.24) })
  vim.api.nvim_set_hl(0, 'UnifiedDelete', { bg = scale(accent.delete, 0.28) })
  vim.api.nvim_set_hl(0, 'UnifiedChange', { bg = scale(accent.change, 0.26) })
end

-- The commit this branch actually forked from, however far master has moved since.
local function merge_base()
  local base = vim.fn.systemlist('git merge-base HEAD origin/master')[1]

  if vim.v.shell_error ~= 0 or not base or base == '' then
    return 'master'
  end

  return base
end

-- Gutter for the review window: right-aligned line number, then the marker to its right.
-- Added/changed lines carry their "+"/"~" as extmark signs, which "%s" renders. Removed
-- lines are virtual lines (v:virtnum < 0) and cannot carry a sign, so draw their "-" here.
-- Continuation rows of a wrapped line get neither a number nor a marker.
function M.review_status_column()
  local virtnum = vim.v.virtnum

  if virtnum < 0 then
    return '%=%#UnifiedDelete#- %*'
  end

  if virtnum > 0 then
    return '%=  '
  end

  return '%=%l %s'
end

-- ----------------------------------------------------------------------------------
-- Folding away the unchanged parts of a reviewed file, the way GitHub collapses them,
-- so a diff to a 5000-line file is a few screens. The plugin marks every changed row
-- with an extmark (added/changed lines carry a highlight, removed lines hang off the
-- row they were removed from), so those rows plus some context are kept and every other
-- stretch of at least two lines is folded.
-- ----------------------------------------------------------------------------------
local FOLD_CONTEXT = 3

function M.fold_text()
  return string.format('  ⋯ %d unchanged lines', vim.v.foldend - vim.v.foldstart + 1)
end

local function fold_unchanged(win)
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local marks = vim.api.nvim_buf_get_extmarks(buf, require('unified.config').ns_id, 0, -1, { details = true })

  vim.api.nvim_win_call(win, function()
    vim.wo.foldmethod = 'manual'
    vim.wo.foldlevel = 0
    vim.wo.foldtext = "v:lua.require'plugins.git'.fold_text()"
    vim.opt_local.fillchars:append({ fold = ' ' })
    vim.cmd('silent! normal! zE') -- drop the folds from the previous render

    if #marks == 0 then
      return
    end

    local keep = {}
    for _, mark in ipairs(marks) do
      local row, details = mark[2] + 1, mark[4]
      if details.line_hl_group or details.virt_lines or details.sign_text then
        for r = row - FOLD_CONTEXT, row + FOLD_CONTEXT do
          keep[r] = true
        end
      end
    end

    local last = vim.api.nvim_buf_line_count(buf)
    local start

    for r = 1, last + 1 do
      if r <= last and not keep[r] then
        start = start or r
      elseif start then
        if r - start >= 2 then
          vim.cmd(string.format('%d,%dfold', start, r - 1))
        end
        start = nil
      end
    end
  end)
end

-- Run one of the file-list actions, then fold whatever it opened in the review window.
local function opening(action)
  return function(...)
    action(...)
    fold_unchanged(require('unified.state').main_win)
  end
end

local function in_review_tab()
  return vim.t.unified_review == true
end

-- Show the working tree diffed against "ref". Opens in its own tab the first time so the
-- layout underneath is untouched; from inside a review, swaps the base in place.
local function open_review(ref)
  vim.fn.system({ 'git', 'rev-parse', '--verify', '--quiet', ref .. '^{commit}' })

  if vim.v.shell_error ~= 0 then
    vim.notify('Unknown git ref: ' .. ref, vim.log.levels.ERROR)
    return
  end

  if in_review_tab() then
    vim.cmd('Unified reset')
    vim.cmd('Unified ' .. ref)
    return
  end

  local launch_tab = vim.api.nvim_get_current_tabpage()
  vim.cmd('Unified -t ' .. ref)

  -- The plugin resolves the ref asynchronously and only then creates the tab, so wait for
  -- its main window to appear in a tab other than this one, then tag and prepare it. That
  -- window is the one every reviewed file opens into, so preparing it once is enough.
  local tries = 0

  local function claim_review_tab()
    tries = tries + 1
    local win = require('unified.state').main_win

    if win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_tabpage(win) ~= launch_tab then
      vim.t[vim.api.nvim_win_get_tabpage(win)].unified_review = true
      -- .vimrc merges signs into the number column; give them their own slot here.
      vim.wo[win].signcolumn = 'yes:1'
      vim.wo[win].statuscolumn = "%{%v:lua.require'plugins.git'.review_status_column()%}"
      fold_unchanged(win)
      return
    end

    if tries < 100 then
      vim.defer_fn(claim_review_tab, 30)
    end
  end

  vim.defer_fn(claim_review_tab, 30)
end

local function close_review()
  vim.cmd('Unified reset')

  if in_review_tab() and #vim.api.nvim_list_tabpages() > 1 then
    vim.cmd('tabclose')
  end
end

local function toggle_review(ref)
  return function()
    if in_review_tab() then
      close_review()
    else
      open_review(ref)
    end
  end
end

function M.setup()
  define_highlights()
  vim.api.nvim_create_autocmd('ColorScheme', { callback = define_highlights, desc = 'Unified diff colours' })

  require('unified').setup({
    highlights = { add = 'UnifiedAdd', delete = 'UnifiedDelete', change = 'UnifiedChange' },
    line_symbols = { add = '+', delete = '-', change = '~' },
    tab = true,
    file_tree = {
      width = 40,
      focus = true -- land in the file list, ready to walk through it
    }
  })

  -- In the file list, moving the cursor opens that file's diff straight away.
  -- "q" there closes the whole review, not just the list.
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'unified_tree',
    callback = function(event)
      local actions = require('unified.file_tree.actions')
      local function map(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = event.buf, desc = desc })
      end

      local open_next = opening(function() actions.move_cursor_and_open_file(1) end)
      local open_prev = opening(function() actions.move_cursor_and_open_file(-1) end)
      local open_this = opening(actions.toggle_node)

      map('j',      open_next,    'Open the next file')
      map('<down>', open_next,    'Open the next file')
      map('k',      open_prev,    'Open the previous file')
      map('<up>',   open_prev,    'Open the previous file')
      map('<cr>',   open_this,    'Open this file')
      map('o',      open_this,    'Open this file')
      map('l',      open_this,    'Open this file')
      map('q',      close_review, 'Close review')
      -- A double click would otherwise select a word; treat it as a click.
      map('<2-LeftMouse>', open_this, 'Open this file')

      -- The plugin parks the cursor on the first file but leaves the window showing
      -- whatever the review was launched from, so the list and the diff disagree until
      -- you move. It places that cursor only once an async "git status" comes back, so
      -- poll briefly for a file to be under the cursor, then open it.
      local tries = 0

      local function open_first_file()
        tries = tries + 1

        if tries > 100 or not vim.api.nvim_buf_is_valid(event.buf) then
          return
        end

        local win = vim.fn.bufwinid(event.buf)

        if win ~= -1 then
          local line = vim.api.nvim_win_get_cursor(win)[1] - 1
          local node = require('unified.file_tree.state').line_to_node[line]

          if node and not node.is_dir then
            vim.api.nvim_win_call(win, opening(actions.toggle_node))
            return
          end
        end

        vim.defer_fn(open_first_file, 30)
      end

      vim.defer_fn(open_first_file, 30)
    end
  })

  -- Clicking a file in the list opens it. Mouse clicks are resolved against the buffer
  -- that has focus *before* the click, so a buffer-local map in the list would only work
  -- on the second click when coming from the diff. Instead let the click land normally
  -- (moving focus and cursor), then open whatever it landed on if that was the list.
  vim.keymap.set('n', '<LeftMouse>', function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<LeftMouse>', true, false, true), 'n', false)

    vim.schedule(function()
      if vim.bo.filetype == 'unified_tree' then
        opening(require('unified.file_tree.actions').toggle_node)()
      end
    end)
  end, { desc = 'Click (opens files in the review list)' })

  local navigation = require('unified.navigation')
  local hunks = require('unified.hunk_actions')

  vim.keymap.set('n', '<leader>vv', toggle_review('HEAD'),                            { desc = 'Review working tree' })
  vim.keymap.set('n', '<leader>vb', function() open_review(merge_base()) end,         { desc = 'Review branch vs master' })
  vim.keymap.set('n', '<leader>vl', function() open_review('HEAD~1') end,             { desc = 'Review last commit' })
  vim.keymap.set('n', '<leader>vp', function() require('unified').pick_commit() end,  { desc = 'Review against a picked commit' })
  vim.keymap.set('n', '<leader>vq', close_review,                                     { desc = 'Close review' })

  vim.keymap.set('n', '<leader>vh', function() Snacks.picker.git_log() end,           { desc = 'Repo history' })
  vim.keymap.set('n', '<leader>vf', function() Snacks.picker.git_log_file() end,      { desc = 'File history' })

  vim.keymap.set('n', ']h', navigation.next_hunk,                                     { desc = 'Next hunk' })
  vim.keymap.set('n', '[h', navigation.previous_hunk,                                 { desc = 'Previous hunk' })

  -- The same on <C-]> / <C-t>, vim's tag-jump pair. In any buffer that is not showing a
  -- review diff the keys keep their normal meaning (<C-[> is not an option: in a
  -- terminal it is indistinguishable from <Esc>).
  local function in_review_or(key, move)
    local default = vim.api.nvim_replace_termcodes(key, true, false, true)

    return function()
      if require('unified.state').is_active() and #require('unified.hunk_store').get(0) > 0 then
        move()
      else
        vim.api.nvim_feedkeys(default, 'n', false)
      end
    end
  end

  vim.keymap.set('n', '<C-]>', in_review_or('<C-]>', navigation.next_hunk),     { desc = 'Next hunk (tag jump elsewhere)' })
  vim.keymap.set('n', '<C-t>', in_review_or('<C-t>', navigation.previous_hunk), { desc = 'Previous hunk (tag pop elsewhere)' })
  local function refolding(action)
    return function()
      action()
      vim.defer_fn(function() fold_unchanged(require('unified.state').main_win) end, 100)
    end
  end

  vim.keymap.set('n', '<leader>vs', refolding(hunks.stage_hunk),                      { desc = 'Stage hunk' })
  vim.keymap.set('n', '<leader>vS', refolding(hunks.unstage_hunk),                    { desc = 'Unstage hunk' })
  vim.keymap.set('n', '<leader>vr', refolding(hunks.revert_hunk),                     { desc = 'Revert hunk (discards the change)' })
end

return M
