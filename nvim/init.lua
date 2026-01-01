-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set runtime path to include your old ~/.vim and ~/.vim/after
vim.opt.runtimepath:prepend(vim.fn.expand("~/.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/.vim/after"))

-- Set packpath to match runtimepath (for plugin compatibility)
vim.opt.packpath = vim.opt.runtimepath:get()

-- Source your old .vimrc
-- vim.cmd("source " .. vim.fn.expand("~/.vimrc"))
vim.cmd('source ~/.vimrc')

require('plugins.nvim-tree').setup()
require('plugins.nvim-treesitter').setup()
require('plugins.nvim-telescope').setup()
require('plugins.neoscroll').setup()
require('plugins.snacks').setup()
require('plugins.opencode').setup()
