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

  -- The "N unchanged lines" fold lines: a dimmed shade of Comment, no background, so
  -- they read as gaps rather than content. Rose-pine's Folded uses the full text colour.
  local comment = vim.api.nvim_get_hl(0, { name = 'Comment', link = false })
  vim.api.nvim_set_hl(0, 'UnifiedFolded', { fg = scale(comment.fg or 0x908caa, 0.6), bg = 'NONE', italic = true })

  -- Snacks' "fancy" diff previews (,vv ,vd ,h ,vf). Its defaults paint *unchanged* context
  -- lines with DiffChange - rose-pine's muddy orange - which reads as if everything changed.
  -- Context gets no background, and add/delete reuse the review's colours so the preview
  -- and the inline review look like the same tool. The LineNr variants are the number
  -- column: a touch lighter than the line, like snacks does itself.
  local line_nr = vim.api.nvim_get_hl(0, { name = 'LineNr', link = false }).fg or 0x6e6a86
  vim.api.nvim_set_hl(0, 'SnacksDiffContext',       { link = 'Normal' })
  vim.api.nvim_set_hl(0, 'SnacksDiffContextLineNr', { link = 'LineNr' })
  vim.api.nvim_set_hl(0, 'SnacksDiffAdd',           { link = 'UnifiedAdd' })
  vim.api.nvim_set_hl(0, 'SnacksDiffDelete',        { link = 'UnifiedDelete' })
  vim.api.nvim_set_hl(0, 'SnacksDiffAddLineNr',     { fg = line_nr, bg = scale(accent.add,    0.32) })
  vim.api.nvim_set_hl(0, 'SnacksDiffDeleteLineNr',  { fg = line_nr, bg = scale(accent.delete, 0.36) })
  -- The words that actually changed within a changed line - a clearly stronger tint.
  vim.api.nvim_set_hl(0, 'SnacksDiffAddWord',       { bg = scale(accent.add,    0.48) })
  vim.api.nvim_set_hl(0, 'SnacksDiffDeleteWord',    { bg = scale(accent.delete, 0.55) })
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

  -- A closed fold ("N unchanged lines") is not a line; leave its gutter empty too.
  if vim.fn.foldclosed(vim.v.lnum) == vim.v.lnum then
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
    vim.opt_local.winhighlight:append({ Folded = 'UnifiedFolded' })
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

-- Everything built on unified.nvim: the inline review, its file list, folding, hunk keys.
-- Only wired up while the plugin is on the runtimepath (its NeoBundle line in .vimrc).
local function setup_unified()
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

  vim.keymap.set('n', '<leader>vu', toggle_review('HEAD'),                            { desc = 'Review working tree (unified)' })
  vim.keymap.set('n', '<leader>vb', function() open_review(merge_base()) end,         { desc = 'Review branch vs master' })
  vim.keymap.set('n', '<leader>vl', function() open_review('HEAD~1') end,             { desc = 'Review last commit' })
  vim.keymap.set('n', '<leader>vp', function() require('unified').pick_commit() end,  { desc = 'Review against a picked commit' })
  vim.keymap.set('n', '<leader>vq', close_review,                                     { desc = 'Close review' })

  vim.keymap.set('n', ']h', navigation.next_hunk,                                     { desc = 'Next hunk' })
  vim.keymap.set('n', '[h', navigation.previous_hunk,                                 { desc = 'Previous hunk' })

  -- The same on <C-]> / <C-t>, vim's tag-jump pair. In any buffer that is not showing a
  -- review diff the keys do whatever they did before: an existing mapping (.vimrc has
  -- <C-]> on coc-diagnostic-next) is replayed, otherwise vim's own behaviour. (<C-[> is
  -- not an option: in a terminal it is indistinguishable from <Esc>.)
  local function in_review_or(key, move)
    local previous = vim.fn.maparg(key, 'n', false, true)
    local default = vim.api.nvim_replace_termcodes(key, true, false, true)

    return function()
      if require('unified.state').is_active() and #require('unified.hunk_store').get(0) > 0 then
        move()
      elseif previous.callback then
        previous.callback()
      elseif previous.rhs and previous.rhs ~= '' then
        local rhs = vim.api.nvim_replace_termcodes(previous.rhs, true, false, true)
        vim.api.nvim_feedkeys(rhs, previous.noremap == 1 and 'n' or 'm', false)
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

-- ----------------------------------------------------------------------------------
-- Word-level emphasis inside snacks' fancy diff, the way GitHub does it: each run of
-- removed lines is paired line-by-line with the run of added lines that follows it,
-- the pair is split into tokens, and the tokens outside their longest common
-- subsequence get a stronger tint. Pairs that share too little are left alone.
-- ----------------------------------------------------------------------------------

-- Words, runs of whitespace, or single other characters, with their byte range.
local function tokenize(text)
  local tokens = {}
  local i = 1

  while i <= #text do
    local from, to = text:find('^[%w_]+', i)
    if not from then from, to = text:find('^%s+', i) end
    if not from then from, to = i, i end
    tokens[#tokens + 1] = { text = text:sub(from, to), from = from, to = to, space = text:sub(from, from):match('%s') ~= nil }
    i = to + 1
  end

  return tokens
end

-- Marks the tokens on each side that are part of the longest common subsequence.
local function mark_common(old, new)
  local n, m = #old, #new
  local dp = {}
  for i = 1, n + 1 do
    dp[i] = {}
    for j = 1, m + 1 do dp[i][j] = 0 end
  end

  for i = n, 1, -1 do
    for j = m, 1, -1 do
      if old[i].text == new[j].text then
        dp[i][j] = dp[i + 1][j + 1] + 1
      else
        dp[i][j] = math.max(dp[i + 1][j], dp[i][j + 1])
      end
    end
  end

  local i, j = 1, 1
  while i <= n and j <= m do
    if old[i].text == new[j].text then
      old[i].kept, new[j].kept = true, true
      i, j = i + 1, j + 1
    elseif dp[i + 1][j] >= dp[i][j + 1] then
      i = i + 1
    else
      j = j + 1
    end
  end
end

-- Byte ranges of the changed tokens, merged; whitespace between two changed tokens
-- counts as changed too, so "a b" reads as one span rather than two islands.
local function changed_ranges(tokens)
  for k, token in ipairs(tokens) do
    if token.kept and token.space and tokens[k - 1] and tokens[k + 1]
      and not tokens[k - 1].kept and not tokens[k + 1].kept then
      token.kept = false
    end
  end

  local ranges = {}
  for _, token in ipairs(tokens) do
    if not token.kept then
      local last = ranges[#ranges]
      if last and last.to == token.from - 1 then
        last.to = token.to
      else
        ranges[#ranges + 1] = { from = token.from, to = token.to }
      end
    end
  end
  return ranges
end

-- Ranges to emphasise on each side of a removed/added pair, or nil when the two lines
-- have too little in common for the emphasis to mean anything.
local function word_diff(old_text, new_text)
  if #old_text > 2000 or #new_text > 2000 then
    return nil
  end

  local old, new = tokenize(old_text), tokenize(new_text)
  if #old > 300 or #new > 300 then
    return nil
  end

  mark_common(old, new)

  local kept_chars, kept_words = 0, 0
  for _, token in ipairs(old) do
    if token.kept then
      kept_chars = kept_chars + #token.text
      if not token.space then kept_words = kept_words + 1 end
    end
  end

  if kept_words == 0 or kept_chars / math.max(#old_text, #new_text) < 0.4 then
    return nil
  end

  return changed_ranges(old), changed_ranges(new)
end

local function emphasise_changed_words()
  local diff = require('snacks.picker.util.diff')
  local format_hunk = diff.format_hunk

  diff.format_hunk = function(ctx)
    local lines = format_hunk(ctx)
    local ok = pcall(function()
      local parse = diff.parse_hunk(ctx)
      if parse.unmerged or (ctx.opts.annotations and #ctx.opts.annotations > 0) then
        return
      end

      local index = diff.build_hunk_index(parse)
      local header = ctx.opts.hunk_header ~= false and #diff.format_hunk_header(parse) or 0
      local last = #parse.versions

      -- The code sits at the end of the line, after the indent that stands in for the
      -- number/prefix columns (and an empty metadata chunk), so its byte offset is the
      -- line's total text length minus the code itself.
      local function add_ranges(l, ranges, group)
        local line = lines[header + l]
        if not line then return end
        local total = 0
        for _, chunk in ipairs(line) do
          if type(chunk[1]) == 'string' and not chunk.virtual and not chunk.inline then
            total = total + #chunk[1]
          end
        end
        local indent = total - #parse.lines[l]
        for _, range in ipairs(ranges) do
          -- Snacks paints its own marks at 4096, and on code tokens those already carry
          -- the line background; the word tint has to sit above them to be seen.
          line[#line + 1] = { col = indent + range.from - 1, end_col = indent + range.to, hl_group = group, priority = 5000 }
        end
      end

      local l = 1
      while l <= parse.len do
        local function removed(k) return index[k] and index[k][1] ~= nil and index[k][last] == nil end
        local function added(k) return index[k] and index[k][last] ~= nil and index[k][1] == nil end

        if removed(l) then
          local removed_from = l
          while removed(l) do l = l + 1 end
          local added_from = l
          while added(l) do l = l + 1 end

          local pairs_count = math.min(added_from - removed_from, l - added_from)
          for k = 0, pairs_count - 1 do
            local old_line, new_line = removed_from + k, added_from + k
            local old_ranges, new_ranges = word_diff(parse.lines[old_line], parse.lines[new_line])
            if old_ranges then
              add_ranges(old_line, old_ranges, 'SnacksDiffDeleteWord')
              add_ranges(new_line, new_ranges, 'SnacksDiffAddWord')
            end
          end
        else
          l = l + 1
        end
      end
    end)
    if not ok then
      -- Never let a highlighting nicety break the preview.
      return format_hunk(ctx)
    end
    return lines
  end
end

-- Snacks' fancy commit header only understands a bare "commit <hash>" line; with
-- decorations on it, it would print the raw line. Strip them off before the original
-- runs, then add a "Refs" line: branches, remotes and tags this commit is the tip of.
local function show_commit_refs()
  local diff = require('snacks.picker.util.diff')
  local format_header = diff.format_header

  diff.format_header = function(ctx)
    local refs
    for i, line in ipairs(ctx.diff.header or {}) do
      local hash, decoration = line:match('^commit%s+(%S+)%s+%((.+)%)%s*$')
      if hash then
        ctx.diff.header[i] = 'commit ' .. hash
        refs = vim.split(decoration, ', ', { plain = true })
      end
    end

    local lines = format_header(ctx)
    if not refs or #lines == 0 then
      return lines
    end

    local row = { { 'Refs', 'SnacksDiffLabel' }, { ': ', 'SnacksPickerDelim' } }
    for k, ref in ipairs(refs) do
      if k > 1 then row[#row + 1] = { ', ', 'SnacksPickerDelim' } end
      local head, target = ref:match('^(HEAD) %-> (.+)$')
      local tag = ref:match('^tag: (.+)$')
      if head then
        row[#row + 1] = { head, 'SnacksPickerGitCommit' }
        row[#row + 1] = { ' -> ', 'SnacksPickerDelim' }
        row[#row + 1] = { target, 'SnacksPickerGitBranch' }
      elseif tag then
        row[#row + 1] = { '\u{f02b} ' .. tag, 'SnacksPickerGitScope' } -- a tag icon, in the "scope" colour
      else
        row[#row + 1] = { ref, 'SnacksPickerGitBranch' }
      end
    end

    table.insert(lines, 2, row) -- right under "Commit:"
    return lines
  end
end

-- The snacks git pickers: history, a commit's files, changed files, hunks.
local function setup_pickers(has_unified)
  emphasise_changed_words()
  show_commit_refs()

  -- Diff pickers fill the screen: a narrow list on the left, the diff preview gets the rest.
  -- They open with the *list* focused, in normal mode - these are for walking, not typing.
  -- "/" or "i" jumps into the search box when a filter is wanted after all.
  local diff_layout = {
    fullscreen = true,
    layout = {
      box = 'horizontal',
      {
        box = 'vertical',
        width = 0.3,
        border = true,
        title = '{title} {live} {flags}',
        { win = 'input', height = 1, border = 'bottom' },
        { win = 'list', border = 'none' }
      },
      { win = 'preview', title = '{preview}', border = true }
    }
  }

  -- Scroll the diff preview a single line, view only, cursor untouched. Bound to
  -- <C-j>/<C-k>, which the list does not need (j/k already walk it); <C-f>/<C-b> keep
  -- their half-window jumps for covering ground.
  local function preview_line(motion)
    local keys = vim.api.nvim_replace_termcodes(motion, true, false, true)

    return function(picker)
      if picker.preview.win:valid() then
        vim.api.nvim_win_call(picker.preview.win.win, function() vim.cmd('normal! ' .. keys) end)
      end
    end
  end

  -- "o" goes one level in, "u" one level up: list -> diff (a normal buffer to scroll and
  -- search) -> back to the list. The commit pickers extend this a level further.
  local function diff_picker(opts)
    return vim.tbl_deep_extend('force', {
      layout = diff_layout,
      focus = 'list',
      -- Through a pipe git never decorates, so the commit preview would never learn about
      -- branches or tags; force it. Rendered by the header hook below.
      previewers = { git = { args = { '-c', 'log.decorate=short' } } },
      actions = {
        preview_line_down = preview_line('<C-e>'),
        preview_line_up = preview_line('<C-y>')
      },
      win = {
        list = {
          keys = {
            ['o'] = 'focus_preview',
            ['<C-j>'] = 'preview_line_down',
            ['<C-k>'] = 'preview_line_up',
            ['/'] = false, -- snacks makes it jump to the filter box; keep vim's own search instead
            ['<C-c>'] = 'cancel', -- snacks only binds it in the search box
            ['<C-l>'] = 'focus_preview' -- the diff is to the right...
          }
        },
        preview = {
          keys = {
            ['o'] = 'focus_list',
            ['u'] = 'focus_list',
            ['<C-c>'] = 'cancel',
            ['<C-h>'] = 'focus_list', -- ...and the list to the left
            -- .vimrc has these as window moves, which would leave the picker and close it.
            ['<C-j>'] = 'preview_line_down',
            ['<C-k>'] = 'preview_line_up'
          }
        },
        -- The same from the search box; "o"/"u" only in normal mode so typing them stays text.
        input = {
          keys = {
            ['o'] = { 'focus_preview', mode = 'n' },
            ['<C-j>'] = { 'preview_line_down', mode = { 'n', 'i' } },
            ['<C-k>'] = { 'preview_line_up', mode = { 'n', 'i' } }
          }
        }
      }
    }, opts)
  end

  -- Commit pickers. Enter drills into the commit: a list of the files it touched, each
  -- previewed with its own diff. <C-o> there goes back to the commits. <C-y> on a commit
  -- opens an inline review against it instead (working tree vs that commit).
  -- Snacks' own default for Enter is "git_checkout", which would detach HEAD.
  local commit_files, commit_log

  -- Put the list cursor on a given commit once the (streamed) log has loaded it, so
  -- coming back from a commit's files lands where you left rather than at the top.
  local function select_commit(picker, sha)
    local tries = 0

    local function attempt()
      tries = tries + 1

      if picker.closed or tries > 100 then
        return
      end

      for idx, item in ipairs(picker:items()) do
        if item.commit == sha then
          picker.list:view(idx)
          return
        end
      end

      vim.defer_fn(attempt, 30)
    end

    attempt()
  end

  commit_files = function(commit, back)
    local parent = commit .. '~1'
    vim.fn.system({ 'git', 'rev-parse', '--verify', '--quiet', parent .. '^{commit}' })

    if vim.v.shell_error ~= 0 then
      parent = '4b825dc642cb6eb9a060e54bf8d69288fbee4904' -- git's empty tree, for a root commit
    end

    Snacks.picker.git_diff(diff_picker({
      title = 'Files in ' .. commit:sub(1, 8),
      cmd_args = { parent, commit },
      group = true,   -- one row per file, not per hunk
      staged = false, -- otherwise the picker would also list the index
      actions = {
        back = function(picker)
          picker:close()
          back()
        end
      },
      win = {
        list = { keys = { ['u'] = 'back', ['<C-o>'] = 'back' } },
        preview = { keys = { ['<C-o>'] = 'back' } },
        input = {
          keys = {
            ['u'] = { 'back', mode = 'n' },
            ['<C-o>'] = { 'back', mode = { 'n', 'i' } },
            -- The git_diff source binds these to stage/restore, which only make sense for
            -- working-tree changes; here a row is a past commit's patch. Plain multi-select
            -- instead, and no restore at all.
            ['<Tab>'] = { 'select_and_next', mode = { 'n', 'i' } },
            ['<c-r>'] = false
          }
        }
      }
    }))
  end

  commit_log = function(opts, selected)
    Snacks.picker.git_log(vim.tbl_deep_extend('force', diff_picker({
      on_show = selected and function(picker) select_commit(picker, selected) end or nil,
      confirm = function(picker, item)
        picker:close()
        if item and item.commit then
          commit_files(item.commit, function() commit_log(opts, item.commit) end)
        end
      end,
      actions = {
        review = function(picker, item)
          picker:close()
          if item and item.commit then open_review(item.commit) end
        end
      },
      win = {
        -- "o" opens the commit here (the files list), rather than hopping to the preview.
        list = { keys = { ['o'] = 'confirm', ['<C-y>'] = has_unified and 'review' or nil } },
        input = { keys = { ['o'] = { 'confirm', mode = 'n' }, ['<C-y>'] = has_unified and { 'review', mode = { 'n', 'i' } } or nil } }
      }
    }), opts or {}))
  end

  vim.keymap.set('n', '<leader>h',  function() commit_log() end,                        { desc = 'Repo history' })
  vim.keymap.set('n', '<leader>vf', function() commit_log({ current_file = true }) end, { desc = 'File history' })
  -- Stage or unstage the selected rows (or the row under the cursor). Snacks' own
  -- git_stage starts one git process per selected row simultaneously, and they trample
  -- each other on .git/index.lock - "select all, stage" ends up staging one file and
  -- failing the rest. Files go in a single git call; hunks (which need "git apply")
  -- run one after another.
  local function stage_selected(picker)
    -- picker:selected() hands out deep copies; the rows themselves are needed so their
    -- status can be rewritten in place afterwards.
    local items = {}
    for _, item in ipairs(picker.list.selected) do
      items[#items + 1] = picker:resolve(item)
    end
    if #items == 0 then
      items = { picker:current() }
    end

    local files, hunks = {}, {}

    for _, item in ipairs(items) do
      if item.status then
        table.insert(files, item)
      elseif item.diff and item.staged ~= nil then
        table.insert(hunks, item)
      end
    end

    if #files == 0 and #hunks == 0 then
      return
    end

    local queue = {}

    -- Toggle the group: unstage only when every selected file is already fully staged.
    local all_staged = #files > 0
    for _, file in ipairs(files) do
      if file.status:sub(2) ~= ' ' then all_staged = false end
    end

    if #files > 0 then
      local cmd = all_staged and { 'git', 'restore', '--staged', '--' } or { 'git', 'add', '--' }
      for _, file in ipairs(files) do table.insert(cmd, file.file) end
      table.insert(queue, { cmd = cmd })
    end

    for _, hunk in ipairs(hunks) do
      local cmd = { 'git', 'apply', '--cached' }
      if hunk.staged then table.insert(cmd, '--reverse') end
      -- Snacks joins the patch lines without a final newline; git apply insists on one.
      table.insert(queue, { cmd = cmd, input = hunk.diff .. '\n' })
    end

    local cwd = items[1].cwd or vim.fn.getcwd()
    local failed = false

    -- Re-running the finder (picker:refresh) empties the list and refills it a frame
    -- later, which reads as a flicker. Instead, once git has succeeded, rewrite what the
    -- rows already know and re-render them where they are.
    local function apply_locally()
      -- Porcelain status is two columns: index, then worktree.
      for _, file in ipairs(files) do
        local index, worktree = file.status:sub(1, 1), file.status:sub(2, 2)

        if all_staged then
          -- restore --staged: the index change goes back to the worktree; a new file becomes untracked.
          file.status = index == 'A' and '??' or (' ' .. (worktree ~= ' ' and worktree or index))
        else
          -- add: the worktree change becomes the index change; untracked becomes added.
          local staged_as = (index ~= ' ' and index ~= '?') and index or (worktree == '?' and 'A' or worktree)
          file.status = staged_as .. ' '
        end
      end

      for _, hunk in ipairs(hunks) do
        hunk.staged = not hunk.staged
      end

      picker.list:set_selected()
      picker.list:update({ force = true })
      picker:show_preview()
    end

    local function run_next()
      local job = table.remove(queue, 1)

      if not job then
        if failed then
          picker:refresh() -- something did not apply; resync with reality
        else
          apply_locally()
        end
        return
      end

      vim.system(job.cmd, { cwd = cwd, stdin = job.input }, vim.schedule_wrap(function(result)
        if result.code ~= 0 then
          failed = true
          vim.notify(table.concat(job.cmd, ' ') .. ' failed:\n' .. vim.trim(result.stderr or ''), vim.log.levels.ERROR)
        end
        run_next()
      end))
    end

    run_next()
  end

  -- Commit what is staged. Opens git's own COMMIT_EDITMSG in a split as a gitcommit
  -- buffer (syntax, spelling, the usual "# Changes to be committed" template); writing it
  -- runs the commit and closes the split, quitting without writing abandons it.
  -- With amend, the last commit's message is pre-filled and staging nothing is fine -
  -- that is how you reword a commit.
  local function commit_staged(opts)
    local amend = opts and opts.amend
    local staged_everything = false
    vim.fn.system({ 'git', 'diff', '--cached', '--quiet' })

    -- Nothing staged: take that as "commit everything", the way a desktop client does -
    -- stage every change, untracked files included, and carry on. With a clean tree a
    -- plain commit has nothing to do, while an amend still makes sense: it is a reword.
    if vim.v.shell_error == 0 then
      vim.fn.system({ 'git', 'add', '--all' })
      vim.fn.system({ 'git', 'diff', '--cached', '--quiet' })

      if vim.v.shell_error ~= 0 then
        staged_everything = true
      elseif not amend then
        vim.notify('Nothing to commit, working tree clean', vim.log.levels.WARN)
        return
      end
    end

    local path = vim.fn.fnamemodify(vim.fn.systemlist({ 'git', 'rev-parse', '--git-path', 'COMMIT_EDITMSG' })[1], ':p')
    local template = amend and vim.fn.systemlist({ 'git', 'log', '-1', '--format=%B' }) or { '' }
    local what = amend and 'amend the last commit' or 'commit'
    vim.list_extend(template, { '# Lines starting with "#" are ignored. Write the buffer to ' .. what .. ', :q! to abandon.', '#' })
    if staged_everything then
      vim.list_extend(template, { '# Nothing was staged, so every change (new files included) has been staged for this commit.', '#' })
    end
    for _, line in ipairs(vim.fn.systemlist({ 'git', '-c', 'color.ui=never', 'status' })) do
      template[#template + 1] = '# ' .. line
    end
    vim.fn.writefile(template, path)

    -- Where to land once the split closes: back where the commit was started from, or
    -- failing that the first ordinary window - never the file tree.
    local origin = vim.api.nvim_get_current_win()

    local function return_to_origin()
      if vim.api.nvim_win_is_valid(origin) and vim.bo[vim.api.nvim_win_get_buf(origin)].filetype ~= 'NvimTree' then
        vim.api.nvim_set_current_win(origin)
        return
      end

      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
        if ft ~= 'NvimTree' and vim.api.nvim_win_get_config(win).relative == '' then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    end

    vim.cmd('botright split ' .. vim.fn.fnameescape(path))
    vim.bo.filetype = 'gitcommit'
    vim.bo.bufhidden = 'wipe'
    vim.wo.spell = true
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    -- An amend arrives with its message already in place, so nothing needs typing - but
    -- ":x" only writes a modified buffer, and unwritten means not amended. Start it
    -- modified so ":x" commits; abandoning becomes ":q!", which is the honest signal.
    if amend then
      vim.bo.modified = true
    end

    -- However the split goes away - committed, :q, :q!, :x on an untouched message -
    -- go back where we came from rather than wherever nvim's "previous window" points.
    vim.api.nvim_create_autocmd('WinClosed', {
      pattern = tostring(vim.api.nvim_get_current_win()),
      once = true,
      callback = function() vim.schedule(return_to_origin) end
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
      buffer = 0,
      once = true,
      callback = function(event)
        local cmd = { 'git', 'commit', '--cleanup=strip', '-F', path }
        if amend then table.insert(cmd, '--amend') end
        local result = vim.system(cmd):wait()

        if result.code ~= 0 then
          vim.notify('Commit failed:\n' .. vim.trim(result.stderr .. result.stdout), vim.log.levels.ERROR)
          return
        end

        -- One line, after clearing the ":w" message - a second line would trigger
        -- vim's "Press ENTER" prompt.
        -- Close the split after the write has fully finished, not during it: ":x" and
        -- ":wq" still have their own quit to do, and if the split were already gone that
        -- quit would hit whatever window became current instead. Either way WinClosed
        -- above returns focus.
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(event.buf) then
            vim.api.nvim_buf_delete(event.buf, { force = true })
          end
        end)
        vim.cmd('redraw')
        local lines = vim.split(vim.trim(result.stdout), '\n')
        vim.notify(lines[1] .. (lines[2] and ('  (' .. vim.trim(lines[2]) .. ')') or ''), vim.log.levels.INFO)
      end
    })
  end

  -- Throw away the selected changes (or the one under the cursor), after a yes/no. Files
  -- go back to HEAD whether their change was staged or not; untracked ones are deleted,
  -- since "discard" for a new file can only mean that. Hunks are reverse-applied, from
  -- the index as well when they were staged. There is no undo for any of it.
  local function discard_selected(picker)
    local items = {}
    for _, item in ipairs(picker.list.selected) do
      items[#items + 1] = picker:resolve(item)
    end
    if #items == 0 then
      items = { picker:current() }
    end

    local tracked, untracked, hunks = {}, {}, {}
    for _, item in ipairs(items) do
      if item.status then
        table.insert(item.status == '??' and untracked or tracked, item.file)
      elseif item.diff and item.staged ~= nil then
        table.insert(hunks, item)
      end
    end

    local total = #tracked + #untracked + #hunks
    if total == 0 then
      return
    end

    local parts = {}
    if #tracked > 0 then parts[#parts + 1] = #tracked .. ' file' .. (#tracked > 1 and 's' or '') end
    if #untracked > 0 then parts[#parts + 1] = #untracked .. ' untracked file' .. (#untracked > 1 and 's (deleted)' or ' (deleted)') end
    if #hunks > 0 then parts[#parts + 1] = #hunks .. ' hunk' .. (#hunks > 1 and 's' or '') end
    local what = total == 1 and (tracked[1] or untracked[1] or (hunks[1].file .. ' hunk')) or table.concat(parts, ', ')

    Snacks.picker.util.confirm('Discard changes to ' .. what .. '? This cannot be undone.', function()
      local cwd = items[1].cwd or vim.fn.getcwd()
      local queue = {}

      if #tracked > 0 then
        local cmd = { 'git', 'restore', '--source=HEAD', '--staged', '--worktree', '--' }
        vim.list_extend(cmd, tracked)
        table.insert(queue, { cmd = cmd })
      end
      if #untracked > 0 then
        local cmd = { 'git', 'clean', '--force', '--' }
        vim.list_extend(cmd, untracked)
        table.insert(queue, { cmd = cmd })
      end
      for _, hunk in ipairs(hunks) do
        local cmd = { 'git', 'apply', '--reverse' }
        if hunk.staged then table.insert(cmd, '--index') end
        table.insert(queue, { cmd = cmd, input = hunk.diff .. '\n' })
      end

      local function run_next()
        local job = table.remove(queue, 1)
        if not job then
          picker:refresh() -- rows are gone for good, so a full reload is the right thing here
          return
        end
        vim.system(job.cmd, { cwd = cwd, stdin = job.input }, vim.schedule_wrap(function(result)
          if result.code ~= 0 then
            vim.notify(table.concat(job.cmd, ' ') .. ' failed:\n' .. vim.trim(result.stderr or ''), vim.log.levels.ERROR)
          end
          run_next()
        end))
      end

      run_next()
    end)
  end

  -- Working-tree pickers: <Tab> stages/unstages from the list as well as the search box,
  -- so <C-a> then <Tab> stages everything in one go. "c" commits what is staged, "X"
  -- discards the selection (after confirmation).
  local function worktree_picker(opts)
    return diff_picker(vim.tbl_deep_extend('force', {
      actions = {
        stage_selected = stage_selected,
        discard_selected = discard_selected,
        commit = function(picker)
          picker:close()
          commit_staged()
        end,
        amend = function(picker)
          picker:close()
          commit_staged({ amend = true })
        end
      },
      win = {
        list = { keys = { ['<Tab>'] = 'stage_selected', ['c'] = 'commit', ['C'] = 'amend', ['X'] = 'discard_selected' } },
        input = {
          keys = {
            ['<Tab>'] = { 'stage_selected', mode = { 'n', 'i' } },
            ['c'] = { 'commit', mode = 'n' },
            ['C'] = { 'amend', mode = 'n' },
            ['X'] = { 'discard_selected', mode = 'n' },
            ['<c-r>'] = false -- snacks' own restore: no batching, and it fails on untracked files
          }
        }
      }
    }, opts))
  end

  vim.keymap.set('n', '<leader>vc', function() commit_staged() end,                 { desc = 'Commit staged changes' })
  vim.keymap.set('n', '<leader>vC', function() commit_staged({ amend = true }) end, { desc = 'Amend the last commit' })

  vim.keymap.set('n', '<leader>vv', function() Snacks.picker.git_status(worktree_picker({})) end, { desc = 'Changed files (Tab stages, C-a Tab stages all)' })
  vim.keymap.set('n', '<leader>vd', function() Snacks.picker.git_diff(worktree_picker({})) end,   { desc = 'All hunks (Tab stages)' })
end

function M.setup()
  define_highlights()
  vim.api.nvim_create_autocmd('ColorScheme', { callback = define_highlights, desc = 'Unified diff colours' })

  local has_unified = pcall(require, 'unified')

  if has_unified then
    setup_unified()
  end

  setup_pickers(has_unified)
end

return M
