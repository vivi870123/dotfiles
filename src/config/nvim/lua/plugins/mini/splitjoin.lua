return {
  'echasnovski/mini.splitjoin',
  keys = {
    { 'gS', desc = 'Split/join', mode = { 'o', 'x', 'n' } },
  },
  opts = function()
    local gen_hook = require('mini.splitjoin').gen_hook
    local curly = { brackets = { '%b{}' } }

    return {
      mappings = {
        toggle = 'gS',
        split = '',
        join = '',
      },

      split = {
        hooks_pre = {},
        hooks_post = { gen_hook.add_trailing_separator(curly) },
      },

      join = {
        hooks_pre = {},
        hooks_post = {
          gen_hook.del_trailing_separator(curly),
          gen_hook.pad_brackets(curly),
        },
      },
    }
  end,
}
