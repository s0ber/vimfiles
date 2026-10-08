-- Follow the macOS appearance: rose-pine moon when the system is dark, rose-pine dawn
-- when it is light. Ghostty switches its own theme on the same signal (see its config),
-- and since Normal has no background here, the two have to agree or the terminal shows
-- through with the wrong foregrounds.
local M = {}

local schemes = { dark = 'rose-pine-moon', light = 'rose-pine-dawn' }
-- vim-airline ships only its "dark" theme; the rest come from vim-airline-themes.
-- Dark stays on the theme it has always used.
local airline = { dark = 'dark', light = 'sol' }
local current -- every rose-pine variant reports colors_name "rose-pine", so track it here

-- The page the text actually sits on. Normal has no background here (see transparency),
-- so the terminal's colour shows through: these are Ghostty's two themes.
local pages = { dark = 0x0c1118, light = 0xfaf4ed }

-- Deliberately faint groups, left alone by the contrast pass below.
local keep_faint = {
  UnifiedFolded = true,
  DiffviewDiffDeleteDim = true,
  SnacksPickerDimmed = true
}

local function relative_luminance(colour)
  local function channel(shift)
    local x = (math.floor(colour / shift) % 256) / 255
    return x <= 0.03928 and x / 12.92 or ((x + 0.055) / 1.055) ^ 2.4
  end

  return 0.2126 * channel(65536) + 0.7152 * channel(256) + 0.0722 * channel(1)
end

local function contrast(a, b)
  local x, y = relative_luminance(a), relative_luminance(b)
  if x < y then x, y = y, x end

  return (x + 0.05) / (y + 0.05)
end

local function blend(a, b, ratio)
  local function channel(shift)
    local x, y = math.floor(a / shift) % 256, math.floor(b / shift) % 256
    return math.floor(x * ratio + y * (1 - ratio))
  end

  return channel(65536) * 65536 + channel(256) * 256 + channel(1)
end

-- Rose-pine dawn's muted tones (#9893a5, #d7827e, #ea9d34) sit at a contrast of 2.1-2.7
-- against its own page, which is where "barely visible" file tree and picker rows come
-- from. Mix any such foreground toward the text colour until it reads, leaving the
-- colour's hue recognisable. Only foregrounds a group defines itself are touched, so
-- links keep following their target.
local function ensure_readable(mode)
  local page = pages[mode]
  local text = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).fg
  if not (page and text) then
    return
  end

  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if hl.fg and not hl.link and not keep_faint[name] and contrast(hl.fg, page) < 3.2 then
      local fg, ratio = hl.fg, 0.95

      while ratio > 0 and contrast(fg, page) < 3.2 do
        fg = blend(hl.fg, text, ratio)
        ratio = ratio - 0.05
      end

      hl.fg = fg
      hl.cterm = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end

local function apply(mode, force)
  local scheme = schemes[mode]

  if not scheme or (mode == current and not force) then
    return
  end

  current = mode
  vim.o.background = mode

  -- Ask rose-pine itself for no backgrounds, rather than clearing them afterwards: it
  -- has a transparency mode that defines every group with bg="NONE" from the start, so
  -- there is nothing to race with. Must be set before the colorscheme is applied.
  pcall(function()
    require('rose-pine').setup({ styles = { transparency = true } })
  end)

  pcall(vim.cmd.colorscheme, scheme)

  -- Dark is left exactly as it was; only the light palette needs the help.
  if mode == 'light' then
    ensure_readable(mode)
  end

  -- Airline needs both halves: the variable, which it honours when it initialises (its
  -- command does not exist yet at that point), and the command, which is what re-colours
  -- a bar that is already drawn. The command is scheduled because airline re-picks a
  -- theme of its own in response to the colorscheme change - and lands on "dark", since
  -- no airline theme is named after rose-pine.
  vim.g.airline_theme = airline[mode]

  vim.schedule(function()
    if vim.fn.exists(':AirlineTheme') == 2 and vim.g.airline_theme ~= airline[mode] then
      pcall(vim.cmd, 'AirlineTheme ' .. airline[mode])
    elseif vim.fn.exists(':AirlineRefresh') == 2 then
      pcall(vim.cmd, 'AirlineRefresh')
    end
  end)
end

-- "defaults read" exits non-zero when the key is unset, which is how macOS says "light".
local function system_mode()
  local out = vim.fn.system({ 'defaults', 'read', '-g', 'AppleInterfaceStyle' })

  return (vim.v.shell_error == 0 and out:lower():find('dark')) and 'dark' or 'light'
end

function M.setup()
  -- Synchronously at startup, so a light session never flashes the dark colours.
  apply(system_mode())

  -- Plugins that choose colours of their own initialise on VimEnter - airline picks a
  -- theme there and would overwrite ours - so assert the mode once more after the whole
  -- startup queue has drained. "force", because the mode itself has not changed.
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      vim.schedule(function() apply(current or system_mode(), true) end)
    end
  })

  -- The appearance can only change while nvim is in the background, so checking on
  -- focus is enough - no polling, no timer.
  vim.api.nvim_create_autocmd({ 'FocusGained', 'VimResume' }, {
    callback = function()
      vim.system({ 'defaults', 'read', '-g', 'AppleInterfaceStyle' }, { text = true }, vim.schedule_wrap(function(result)
        apply((result.code == 0 and (result.stdout or ''):lower():find('dark')) and 'dark' or 'light')
      end))
    end,
    desc = 'Follow the macOS appearance'
  })

  -- Something else setting 'background' (a terminal query, :set background=...) switches
  -- the colorscheme to match rather than leaving the two inconsistent.
  vim.api.nvim_create_autocmd('OptionSet', {
    pattern = 'background',
    callback = function() apply(vim.v.option_new) end
  })

  -- ":Appearance light|dark" to force one, ":Appearance" to go back to following macOS.
  vim.api.nvim_create_user_command('Appearance', function(opts)
    apply(opts.args ~= '' and opts.args or system_mode())
  end, { nargs = '?', complete = function() return { 'light', 'dark' } end })
end

return M
