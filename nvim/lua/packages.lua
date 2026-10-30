-- Plugins, managed by lazy.nvim (https://lazy.folke.io). Everything loads at startup, the way
-- NeoBundle did it. Versions are pinned in lazy-lock.json next to init.lua: ":Lazy restore"
-- puts every plugin back on its locked commit, ":Lazy update" moves them and rewrites the lock.
local M = {}

local specs = {
  'vim-airline/vim-airline',             -- light version of powerline
  'vim-airline/vim-airline-themes',      -- airline ships only its dark theme; the rest live here
  'tpope/vim-repeat',                    -- repeat custom actions with .

  -- text formatting
  'jiangmiao/auto-pairs',                -- autoclose quotes, brackets, etc
  'tpope/vim-surround',                  -- quote selected text
  'tomtom/tcomment_vim',                 -- comment and uncomment
  'vim-scripts/DeleteTrailingWhitespace', -- remove trailing whitespaces
  'mg979/vim-visual-multi',              -- sublime-inspired multiple cursors

  -- integration with ag
  'rking/ag.vim',
  'gabesoft/vim-ags',

  -- smooth scrolling
  'karb94/neoscroll.nvim',

  -- fuzzy search
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',

  -- file tree
  'nvim-tree/nvim-tree.lua',

  -- filetypes support
  'kchmck/vim-coffee-script',            -- support for coffeescript
  'vim-ruby/vim-ruby',                   -- support for ruby (always use latest vim-ruby)
  'tpope/vim-haml',                      -- support for haml
  'slim-template/vim-slim',              -- support for slim
  'othree/html5.vim',                    -- support for html5
  'derekwyatt/vim-scala',                -- support for scala
  'groenewege/vim-less',                 -- support for less
  'digitaltoad/vim-pug',                 -- support for pug (former Jade)
  'Eric-Song-Nop/vim-glslx',
  -- main needs nvim 0.12; master's queries break on 0.12 - see lua/plugins/nvim-treesitter.lua
  { 'nvim-treesitter/nvim-treesitter', branch = 'main', build = ':TSUpdate' },
  'RRethy/nvim-treesitter-endwise',      -- automatically end code blocks

  'folke/snacks.nvim',
  'NickvanDyke/opencode.nvim',

  -- git
  -- inline unified diffs - parked, snacks covers it; uncomment to bring the review back
  -- { 'axkirillov/unified.nvim', branch = 'scroll-deleted-lines-horizontally' },

  -- colorscheme
  'vv9k/vim-github-dark',
  { 'dracula/vim', name = 'dracula' },
  'gmr458/vscode_modern_theme.nvim',
  'folke/tokyonight.nvim',
  { 'catppuccin/nvim', name = 'catppuccin' },
  { 'rose-pine/neovim', name = 'rose-pine' },
  'nyoom-engineering/oxocarbon.nvim',
  'rebelot/kanagawa.nvim',
  'EdenEast/nightfox.nvim',
  'loctvl842/monokai-pro.nvim',

  -- typescript IDE 2
  { 'neoclide/coc.nvim', build = 'npm ci' },

  -- tests runners
  'vim-test/vim-test',
}

function M.setup()
  local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
  if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath })
  end
  vim.opt.rtp:prepend(lazypath)

  require('lazy').setup(specs, {
    defaults = { lazy = false },
    install = { colorscheme = { 'rose-pine-moon' } },
    change_detection = { notify = false },
    -- Keep ~/.vim and ~/.vim/after (prepended in init.lua) on the runtimepath.
    performance = { rtp = { reset = false } },
  })
end

return M
