local M = {}

function M.setup()
  local VIEW_WIDTH_FIXED = 32
  local view_width_max = VIEW_WIDTH_FIXED -- fixed to start

  -- toggle the width and redraw
  local function toggle_width_adaptive()
    if view_width_max == -1 then
      view_width_max = VIEW_WIDTH_FIXED
    else
      view_width_max = -1
    end

    require("nvim-tree.api").tree.reload()
  end

  local function search_in_dir_ag()
    local api = require("nvim-tree.api")

    -- Get the selected node (file or directory) in NvimTree
    local node = api.tree.get_node_under_cursor()
    if not node then
      vim.notify("Maybe another time..", vim.log.levels.WARN)
      return
    end

    -- Get directory to search in
    local dir = node.absolute_path
    if node.type == "file" then
      dir = vim.fn.fnamemodify(dir, ":h")
    end

    -- Ask for the search pattern
    vim.ui.input({ prompt = "Enter the pattern: " }, function(pattern)
      if not pattern or pattern == "" then
        vim.notify("Maybe another time..", vim.log.levels.INFO)
        return
      end

      -- Unfocus nvim-tree (assumes it's in a vertical split)
      -- and move to the right/next window
      vim.cmd("wincmd l")

      -- Run ag in a new quickfix window
      local cmd = "Ag! -i " .. vim.fn.shellescape(pattern) .. " " .. vim.fn.shellescape(dir)
      vim.cmd(cmd)
    end)
  end

  local function search_in_dir_telescope()
    local api = require("nvim-tree.api")

    -- Get the selected node (file or directory) in NvimTree
    local node = api.tree.get_node_under_cursor()
    if not node then
      vim.notify("Maybe another time..", vim.log.levels.WARN)
      return
    end

    -- Get directory to search in
    local dir = node.absolute_path
    if node.type == "file" then
      dir = vim.fn.fnamemodify(dir, ":h")
    end

    -- Unfocus nvim-tree (assumes it's in a vertical split)
    -- and move to the right/next window
    vim.cmd("wincmd l")

    -- Run telescope
    return require('telescope.builtin').live_grep({ search_dirs = { dir } })
  end


  local api = require('nvim-tree.api')
  -- Custom function to add marked files to quickfix
  local function marked_to_quickfix()
    local marks = api.marks.list()
    if #marks == 0 then
      print("No marked files")
      return
    end

    local qf_list = {}
    for _, node in ipairs(marks) do
      table.insert(qf_list, {
        filename = node.absolute_path,
        lnum = 1,
      })
    end

    vim.fn.setqflist(qf_list)
    vim.cmd('copen')
  end


  local function my_on_attach(bufnr)
    local api = require "nvim-tree.api"

    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- custom mappings
    -- vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent,        opts('Up'))
    -- vim.keymap.set('n', '?',     api.tree.toggle_help,                  opts('Help'))

    vim.keymap.set("n", "P",              api.fs.paste,                       opts("Paste"))
    vim.keymap.set("n", "p",              api.node.navigate.parent,           opts("Parent Directory"))
    vim.keymap.set("n", "S",              api.node.run.system,                opts("Run System"))
    vim.keymap.set("n", "s",              search_in_dir_telescope,            opts("Search"))
    vim.keymap.set("n", "R",              api.fs.rename,                      opts("Rename"))
    vim.keymap.set("n", "r",              api.tree.reload,                    opts("Refresh"))
    vim.keymap.set('n', 'A',              toggle_width_adaptive,              opts('Toggle Adaptive Width'))
    vim.keymap.set("n", "u",              api.tree.change_root_to_parent,     opts("Up"))
    vim.keymap.set("n", "O",              api.node.open.edit,                 opts("Open"))
    vim.keymap.set("n", "o",              api.node.open.no_window_picker,     opts("Open: No Window Picker"))

    vim.keymap.set('n', '<c-q>',      marked_to_quickfix,                 opts("Open Marked in quickfix list"))
    vim.keymap.set('n', '<c-u>',      api.marks.clear,                    opts('Unmark all files'))
  end

  -- get current view width
  local function get_view_width_max()
    return view_width_max
  end

  require("nvim-tree").setup {
    on_attach = my_on_attach,
    actions = {
      change_dir = {
        global = true
      }
    },
    view = {
      width = {
        min = 32,
        max = get_view_width_max
      }
    },
    renderer = {
      hidden_display = "all"
    }
  }
end

return M
