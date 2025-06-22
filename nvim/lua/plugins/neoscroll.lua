local M = {}

function M.setup()
  require('neoscroll').setup({
    mappings = {'<C-u>', '<C-d>'},
    duration_multiplier = 0.4,
    hide_cursor = false,
    easing = 'sine'
  })
end

return M
