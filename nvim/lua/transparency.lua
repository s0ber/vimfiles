-- Keep the terminal background showing through. Rose-pine is asked for its own
-- transparency mode (see appearance.lua), which covers everything it defines - this is
-- the fallback for groups that come from somewhere else.
local M = {}

-- Groups that paint a background over the terminal. Anything the current colorscheme
-- does not define is skipped, so this list can name groups from plugins that may not be
-- loaded. Title groups are deliberately absent: they are small coloured chips, usually
-- linked to a shared group, and clearing the background breaks the link and the look.
local groups = {
  'Normal', 'NormalNC', 'NormalFloat', 'FloatBorder',
  'SignColumn', 'LineNr', 'EndOfBuffer', 'NonText', 'MsgArea',
  'WinSeparator', 'VertSplit', 'Folded', 'FoldColumn',
  'NvimTreeNormal', 'NvimTreeNormalNC', 'NvimTreeEndOfBuffer', 'NvimTreeWinSeparator',
  'TelescopeNormal', 'TelescopeBorder',
  'SnacksNormal', 'SnacksNormalNC', 'SnacksWinBorder',
  'TelescopePromptNormal', 'TelescopePromptBorder',
  'TelescopeResultsNormal', 'TelescopeResultsBorder',
  'TelescopePreviewNormal', 'TelescopePreviewBorder',
  'SnacksNormal', 'SnacksNormalNC', 'SnacksWinBorder',
  'SnacksPicker', 'SnacksPickerNormal', 'SnacksPickerBorder',
  'SnacksPickerInput', 'SnacksPickerInputBorder', 'SnacksPickerList', 'SnacksPickerPreview',
  'SnacksPickerPreviewBorder', 'SnacksPickerListBorder', 'SnacksPickerBoxBorder'
}

-- Drop just the background, keeping every other attribute the colorscheme set.
--
-- Via ":highlight", which merges into the existing group, rather than by handing the
-- table from nvim_get_hl back to nvim_set_hl: that round trip can fail on attributes the
-- getter reports but the setter will not accept, and the failure is silent.
local function clear_background(group)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })

  if not ok or vim.tbl_isempty(hl) or (hl.bg == nil and hl.ctermbg == nil) then
    return
  end

  local applied, err = pcall(vim.cmd, ('highlight %s guibg=NONE ctermbg=NONE'):format(group))

  if not applied then
    vim.notify(('transparency: could not clear %s: %s'):format(group, err), vim.log.levels.WARN)
  end
end

local function clear_backgrounds()
  vim.iter(groups):each(clear_background)
end

function M.setup()
  -- Re-apply on every colorscheme change, so switching themes keeps the terminal showing.
  vim.api.nvim_create_autocmd('ColorScheme', {
    callback = clear_backgrounds,
    desc = 'Keep the terminal background showing through'
  })

  -- ".vimrc" already ran "colorscheme", so the current one needs doing by hand.
  clear_backgrounds()
end

return M
