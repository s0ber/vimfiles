-- Over SSH there is no Wayland clipboard, so with clipboard=unnamedplus yanks never leave
-- nvim. Send them to the client terminal (the Mac) with OSC 52 instead.
--
-- Pasting does not ask the terminal for its clipboard (OSC 52 read): Mac terminals either
-- show a permission prompt or never answer, which stalls every `p` for 10s. `p` returns
-- the last yank made in this nvim; Cmd+V pastes from the Mac clipboard.
local M = {}

function M.setup()
  if not (vim.env.SSH_TTY or vim.env.SSH_CONNECTION) then
    return
  end

  local osc52 = require('vim.ui.clipboard.osc52')
  local last = {}

  local function copy(reg)
    local send = osc52.copy(reg)
    return function(lines, regtype)
      last[reg] = { lines, regtype }
      send(lines)
    end
  end

  local function paste(reg)
    return function()
      return last[reg] or { { '' }, 'v' }
    end
  end

  vim.g.clipboard = {
    name = 'OSC 52 (SSH)',
    copy = { ['+'] = copy('+'), ['*'] = copy('*') },
    paste = { ['+'] = paste('+'), ['*'] = paste('*') },
  }
end

return M
