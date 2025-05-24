local M = {}

function M.setup()
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'javascript', 'typescript', 'tsx', 'json', 'html', 'css', 'scss', 'lua', 'vim', 'query', 'ruby', 'slim' },
    highlight = {
      enable = true,
      vim.api.nvim_set_hl(0, "@variable.builtin.javascript", { link = "@variable" })
    },
    indent = { enable = true }
  }
end

return M
