return {
  'rebelot/heirline.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  opts = function()
    return {
      statusline = require 'plugins.heirline.statusline',
    }
  end,
  config = function(_, opts)
    vim.o.showcmdloc = 'statusline'
    vim.g.qf_disable_statusline = true

    require('heirline').setup(opts)

    mines.augroup('Heirline', {
      event = 'ColorScheme',
      command = function() require('heirline.utils').on_colorscheme() end,
    })
  end,
}
