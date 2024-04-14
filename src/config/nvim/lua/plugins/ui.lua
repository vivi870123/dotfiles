
local lspkind = require 'lspkind'

return {
  {
    'stevearc/dressing.nvim',
    lazy = false,
    enabled = false,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      ui.input = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.input(...)
      end

      ui.select = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.select(...)
      end
    end,
    opts = {
      input = {
        enable = true,
        border = border,
        insert_only = true,
        win_options = { winblend = 2 },
      },
      select = {
        backend = { 'telescope', 'builtin', 'nui' },
        builtin = {
          border = border,
          min_height = 10,
          win_options = { winblend = 10 },
          mappings = { n = { ['q'] = 'Close' } },
        },
      },
      nui = { min_height = 10, win_options = { winblend = 10 } },
      get_config = function(opts)
        if opts.kind == 'read_url' then return {
          relative = 'win',
          prefer_width = 60,
        } end

        if opts.kind == 'codeaction' then return { backend = 'telescope', telescope = mines.telescope.cursor() } end
      end,
    },
  }, -- dressing.nvim
  {
    'rcarriga/nvim-notify',
    enabled = false,
    config = function()
      highlight.plugin('notify', {
        { NotifyERRORBorder = { bg = { from = 'NormalFloat' } } },
        { NotifyWARNBorder = { bg = { from = 'NormalFloat' } } },
        { NotifyINFOBorder = { bg = { from = 'NormalFloat' } } },
        { NotifyDEBUGBorder = { bg = { from = 'NormalFloat' } } },
        { NotifyTRACEBorder = { bg = { from = 'NormalFloat' } } },
        { NotifyERRORBody = { link = 'NormalFloat' } },
        { NotifyWARNBody = { link = 'NormalFloat' } },
        { NotifyINFOBody = { link = 'NormalFloat' } },
        { NotifyDEBUGBody = { link = 'NormalFloat' } },
        { NotifyTRACEBody = { link = 'NormalFloat' } },
      })

      local notify = require 'notify'

      notify.setup {
        timeout = 5000,
        stages = 'fade_in_slide_out',
        top_down = false,
        background_colour = 'NormalFloat',
        max_width = function() return math.floor(vim.o.columns * 0.6) end,
        max_height = function() return math.floor(vim.o.lines * 0.8) end,
        on_open = function(win)
          if not api.nvim_win_is_valid(win) then return end
          api.nvim_win_set_config(win, { border = border })
        end,
        render = function(...)
          local notification = select(2, ...)
          local style = falsy(notification.title[1]) and 'minimal' or 'default'
          require('notify.render')[style](...)
        end,
      }
      map('n', '<leader>nd', function() notify.dismiss { silent = true, pending = true } end, {
        desc = 'dismiss notifications',
      })
    end,
  }, -- nvim-notify
}

