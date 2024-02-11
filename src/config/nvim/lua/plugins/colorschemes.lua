return {
  { -- doom-one.nvim
    'NTBBloodbath/doom-one.nvim',
    lazy = false,
    config = function()
      vim.g.doom_one_pumblend_enable = true
      vim.g.doom_one_pumblend_transparency = 3
    end,
  },
  { -- tokyonight.nvim
    'folke/tokyonight.nvim',
    opts = { style = 'night' },
    lazy = false,
  },
  { -- kanagawa.nvim
    'rebelot/kanagawa.nvim',
    lazy = false,
    opts = {
      background = {
        light = 'dragon',
        dark = 'lotus',
      },
    },
  },
  { -- nightfox.nvim
    'EdenEast/nightfox.nvim',
    lazy = false,
  },
}
