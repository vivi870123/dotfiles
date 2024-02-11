return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    local highlight = mines.highlight
    local wk = require 'which-key'

    highlight.plugin('whichkey', {
      theme = {
        ['*'] = { { WhichkeyFloat = { link = 'NormalFloat' } } },
      },
    })

    wk.setup {
      plugins = { spelling = { enabled = true } },
      window = { border = mines.ui.current.border },
      layout = { align = 'center' },
    }

    wk.register {
      [']'] = { name = '+next' },
      ['['] = { name = '+prev' },
      g = {
        c = { name = '+comment' },
        b = { name = '+bufferline' },
      },
  ['<leader>'] = {
        a = { name = '+projectionist' },
        c = { name = '+code-action' },
        f = { name = '+picker' },
        g = { name = '+git-action' },

        n = { name = '+new' },
        j = { name = '+jump' },
        p = { name = '+packages' },
        q = { name = '+quit' },
        l = { name = '+list' },
        i = { name = '+iswap' },
        e = { name = '+edit' },
        r = { name = '+lsp-refactor' },
        o = { name = '+only' },
        t = { name = '+tab' },
        s = { name = '+source/swap' },
        y = { name = '+yank' },
        O = { name = '+options' },
      },
    }
  end,
}
