local M = {}

local languages = { 'javascript', 'typescript', 'tsx', 'json', 'html', 'css', 'scss', 'lua', 'vim', 'query', 'ruby', 'slim', 'regex', 'markdown', 'markdown_inline' }

-- Ruby keeps vim's regex syntax on top of treesitter, as it always had.
local with_regex_syntax = { ruby = true }

function M.setup()
  -- No-op for parsers already installed; runs in the background otherwise.
  require('nvim-treesitter').install(languages)

  -- .vimrc sets *.tsx to "typescript.tsx"; parse it with the tsx parser.
  vim.treesitter.language.register('tsx', 'typescript.tsx')

  -- The main branch only provides parsers and queries; highlighting is nvim's own and has
  -- to be started per buffer.
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(event)
      local lang = vim.treesitter.language.get_lang(event.match)

      if not vim.tbl_contains(languages, lang) or not pcall(vim.treesitter.start, event.buf, lang) then
        return
      end

      if with_regex_syntax[lang] then
        vim.bo[event.buf].syntax = 'on'
      end
    end,
    desc = 'Treesitter highlighting'
  })
end

return M
