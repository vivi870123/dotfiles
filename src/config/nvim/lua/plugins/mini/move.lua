return {
  'echasnovski/mini.move',
  event = 'VeryLazy',
  keys = {
    { ']e', mode = { 'n', 'v' } },
    { '[e', mode = { 'n', 'v' } },
  },
  opts = {
    mappings = {
      -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
      left = '',
      right = '',
      down = ']e',
      up = '[e',

      -- Move current line in Normal mode
      line_left = '',
      line_right = '',
      line_down = ']e',
      line_up = '[e',
    },
  },
}
