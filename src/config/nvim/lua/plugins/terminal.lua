local fn = vim.fn
local keymap = vim.keymap.del
local border = mines.ui.current.border
local command, falsy = mines.command, mines.falsy

return {
  'akinsho/toggleterm.nvim',
  enabled = true,
  event = 'VeryLazy',
  opts = {
    open_mapping = [[<leader>tt]],
    shade_filetypes = {},
    direction = 'horizontal',
    autochdir = true,
    persist_mode = true,
    insert_mappings = false,
    start_in_insert = true,
    winbar = { enabled = false },
    highlights = {
      FloatBorder = { link = 'FloatBorder' },
      NormalFloat = { link = 'NormalFloat' },
    },
    float_opts = { border = border, winblend = 3 },
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    local float_handler = function(term)
      if not falsy(fn.mapcheck('jk', 't')) then
        keymap.del('t', 'jk', { buffer = term.bufnr })
        keymap.del('t', '<esc>', { buffer = term.bufnr })
      end
    end

    local Terminal = require('toggleterm.terminal').Terminal

    local htop = Terminal:new {
      cmd = 'htop',
      hidden = true,
      direction = 'float',
      on_open = float_handler,
      highlights = {
        FloatBorder = { guibg = 'Black', guifg = 'DarkGray' },
        NormalFloat = { guibg = 'Black' },
      },
    }

    command('Htop', function() htop:toggle() end)
  end,
}
