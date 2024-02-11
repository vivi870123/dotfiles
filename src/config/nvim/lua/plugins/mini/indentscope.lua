return {
  'echasnovski/mini.indentscope',
  lazy = false,
  opts = function()
    return {
      symbol = '│',
      options = {
        border = 'both',
        indent_at_cursor = true,
        try_as_border = true,
      },
      mappings = {
        object_scope = 'ii',
        object_scope_with_border = 'ai',
      },
      draw = {
        delay = 100,
        animation = require('mini.indentscope').gen_animation.none(),
      },
    }
  end,
  config = function(_, opts)
    require('mini.indentscope').setup(opts)

    require('util.mini').disable_mini_module('indentscope', {
      terminal = true,
      filetype = {
        'alpha',
        'dashboard',
        'starter',
        'help',
        'neo-tree',
        'neo-*',
        'Trouble',
        'notify',
        'NvimTree',
        'lazy',
        'mason',
        'toggleterm',
      },
      buftype = { 'quickfix' },
    })
  end,
}
