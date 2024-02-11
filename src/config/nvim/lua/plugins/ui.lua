local api = vim.api
local highlight, ui, falsy = mines.highlight, mines.ui, mines.falsy
local border = ui.current.border

local lspkind = require 'lspkind'

return {
  { -- dressing.nvim
    'stevearc/dressing.nvim',
    enabled = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      ui.input = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.input(...)
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
  },
  { -- zen-mode.nvim
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    keys = {
      { '<leader>Z', '<cmd>ZenMode<cr>', desc = 'ZenMode' },
    },
    dependencies = {
      { -- twilight.nvim
        'folke/twilight.nvim',
        cmd = { 'Twilight', 'TwilightEnable', 'TwilightDisable' },
        opts = {
          dimming = { alpha = 0.25, inactive = false },
          context = 10,
          treesitter = true,
          expand = { 'function', 'method', 'table', 'if_statement' },
          exclude = {},
        },
      },
    },
    opts = {
      window = {
        backdrop = 0.98,
        width = 82,
        height = 1,
        options = {
          signcolumn = 'no',
          number = false,
          relativenumber = false,
        },
      },
      plugins = {
        tmux = { enabled = true },
        twilight = { enabled = true },
        gitsigns = { enabled = false },
        kitty = { enabled = true, font = '+2' },
      },
    },
  },
  { -- dropbar.nvim
    'Bekaboo/dropbar.nvim',
    event = 'VeryLazy',
    enabled = mines.ui.winbar.enable,
    keys = {
      { '<leader>wp', function() require('dropbar.api').pick() end, desc = 'winbar: pick' },
    },
    init = function()
      highlight.plugin('DropBar', {
        { DropBarIconUISeparator = { link = 'Delimiter' } },
        { DropBarMenuNormalFloat = { inherit = 'Pmenu' } },
      })
    end,
    opts = {
      general = {
        update_interval = 100,
        enable = function(buf, win)
          local b, w = vim.bo[buf], vim.wo[win]
          local decor = ui.decorations.get { ft = b.ft, bt = b.bt, setting = 'winbar' }
          return decor.ft ~= false
            and decor.bt ~= false
            and b.bt == ''
            and not w.diff
            and not api.nvim_win_get_config(win).zindex
            and api.nvim_buf_get_name(buf) ~= ''
        end,
      },
      icons = {
        ui = {
          bar = {
            separator = ' ' .. ui.icons.misc.arrow_right .. ' ',
          },
        },
        kinds = {
          symbols = vim.tbl_map(function(value) return value .. ' ' end, lspkind.symbol_map),
        },
      },
      menu = {
        win_configs = {
          border = 'shadow',
          col = function(menu) return menu.prev_menu and menu.prev_menu._win_configs.width + 1 or 0 end,
        },
      },
    },
  },
  { -- nvim-notify
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
  },
  { -- nvim-ufo
    'kevinhwang91/nvim-ufo',
    enabled = true,
    event = 'VeryLazy',
    dependencies = { 'kevinhwang91/promise-async' },
    keys = {
      { 'zR', function() require('ufo').openAllFolds() end, 'open all folds' },
      { 'zM', function() require('ufo').closeAllFolds() end, 'close all folds' },
      { 'zp', function() require('ufo').peekFoldedLinesUnderCursor() end, 'preview fold' },
    },
    opts = function()
      return {
        open_fold_hl_timeout = 0,
        preview = { win_config = { winhighlight = 'Normal:Normal,FloatBorder:Normal' } },
        enable_get_fold_virt_text = true,
        close_fold_kinds = { 'imports', 'comment' },
        provider_selector = function(_, ft)
          local ft_map = { rust = 'lsp' }
          return ft_map[ft] or { 'treesitter', 'indent' }
        end,
      }
    end,
  },
  { -- ccc.nvim
    'uga-rosa/ccc.nvim',
    event = { 'BufRead', 'BufNewFile' },
    keys = {
      { '<leader>cp', '<cmd>CccPick<cr>', desc = 'Pick' },
      { '<leader>cc', '<cmd>CccConvert<cr>', desc = 'Convert' },
      { '<leader>th', '<cmd>CccHighlighterToggle<cr>', desc = 'Toggle Highlighter' },
    },
    opts = function()
      local ccc = require 'ccc'
      local p = ccc.picker

      p.hex.pattern = {
        [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)>]=],
        [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)(\x\x)>]=],
      }

      return {
        win_opts = { border = border },
        pickers = {
          p.hex,
          p.css_rgb,
          p.css_hsl,
          p.css_hwb,
          p.css_lab,
          p.css_lch,
          p.css_oklab,
          p.css_oklch,
        },
        highlighter = {
          auto_enable = true,
          lsp = true,
          inputs = { ccc.input.hsl, ccc.input.rgb },
          filetypes = {
            'conf',
            'lua',
            'css',
            'javascript',
            'sass',
            'typescript',
            'javascriptreact',
            'typescriptreact',
          },
          excludes = {
            'lazy',
            'mason',
            'neo-tree',
            'orgagenda',
            'org',
            'NeogitStatus',
            'toggleterm',
          },
        },
        recognize = { input = true, output = true },
        mappings = {
          ['?'] = function()
            print 'i - Toggle input mode'
            print 'o - Toggle output mode'
            print 'a - Toggle alpha slider'
            print 'g - Toggle palette'
            print 'w - Go to next color in palette'
            print 'b - Go to prev color in palette'
            print 'l/d/, - Increase slider'
            print 'h/s/m - Decrease slider'
            print '1-9 - Set slider value'
          end,
        },
      }
    end,
  },
}
