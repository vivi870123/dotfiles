return {
  'echasnovski/mini.notify',
  lazy = false,
  config = function()
    local filterout_lua_diagnosing = function(notif_arr)
      local not_diagnosing = function(notif) return not vim.startswith(notif.msg, 'lua_ls: Diagnosing') end
      notif_arr = vim.tbl_filter(not_diagnosing, notif_arr)
      return require('mini.notify').default_sort(notif_arr)
    end

    require('mini.notify').setup {
      content = {
        sort = filterout_lua_diagnosing,
      },
      window = {
        config = {
          border = mines.ui.current.border,
        },
      },
    }

    vim.notify = require('mini.notify').make_notify()
  end
}
