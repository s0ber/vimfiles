local M = {}

-- Groups that paint a background over the terminal. Anything not defined by the current
-- colorscheme is skipped, so this list can name groups from plugins that may not be loaded.
local groups = {
  'Normal', 'NormalNC', 'NormalFloat', 'FloatBorder', 'FloatTitle',
  'SignColumn', 'LineNr', 'EndOfBuffer', 'NonText', 'MsgArea',
  'WinSeparator', 'VertSplit', 'Folded', 'FoldColumn',
  'NvimTreeNormal', 'NvimTreeNormalNC', 'NvimTreeEndOfBuffer', 'NvimTreeWinSeparator',
  'TelescopeNormal', 'TelescopeBorder',
  'SnacksNormal', 'SnacksNormalNC', 'SnacksWinBorder'
}

-- Drop just the background, keeping every other attribute the colorscheme set.
local function clear_background(group)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })

  if not ok or vim.tbl_isempty(hl) or (hl.bg == nil and hl.ctermbg == nil) then
    return
  end

  hl.bg, hl.ctermbg = nil, nil
  pcall(vim.api.nvim_set_hl, 0, group, hl)
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
