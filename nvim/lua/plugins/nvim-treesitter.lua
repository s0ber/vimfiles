local M = {}

function M.setup()
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'javascript', 'typescript', 'tsx', 'json', 'html', 'css', 'scss', 'lua', 'vim', 'query', 'ruby', 'slim' },
    highlight = {
      enable = true,
      -- vim.api.nvim_set_hl(0, "@variable.builtin.javascript", { link = "@variable" }),
      -- vim.api.nvim_set_hl(0, "@variable.ruby", { link = "@variable.builtin" }),
      -- vim.api.nvim_set_hl(0, "@function.call.ruby", { link = "@variable.member" }),
      -- vim.api.nvim_set_hl(0, "@function.call.ruby", { link = "@function.method.call" }),
      -- vim.api.nvim_set_hl(0, "@type.ruby", { link = "@variable" })
    },
    indent = { enable = false }
  }
end

return M
