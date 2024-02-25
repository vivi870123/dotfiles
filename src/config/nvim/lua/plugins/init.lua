local api = vim.api
local sys, augroup, command = require 'sys', mines.augroup, mines.command

return {
  -----------------------------------------------------------------------------//
  -- Core
  -----------------------------------------------------------------------------//
  {
    'MunifTanjim/nui.nvim',
    lazy = false,
  }, -- nui.nvim
  {
    'willothy/flatten.nvim',
    lazy = false,
    priority = 1001,
    opts = {
      window = { open = 'alternate' },
      callbacks = {
        block_end = function() require('toggleterm').toggle() end,
        post_open = function(_, winnr, _, is_blocking)
          if is_blocking then
            require('toggleterm').toggle()
          else
            api.nvim_set_current_win(winnr)
          end
        end,
      },
    },
  }, -- willothy/flatten.nvim
  {
    'nvim-tree/nvim-web-devicons',
    lazy = false,
    dependencies = { 'DaikyXendo/nvim-material-icon' },
    config = function()
      require('nvim-web-devicons').setup {
        override = require('nvim-material-icon').get_icons(),
      }
    end,
  }, -- nvim-web-devicons,


  -----------------------------------------------------------------------------//
  -- Quickfix
  -----------------------------------------------------------------------------//
  {
    'kevinhwang91/nvim-bqf',
    opts = {
      auto_resize_height = true,
      func_map = {
        tab = 'st',
        split = 'sv',
        vsplit = 'sg',
        stoggleup = 'K',
        stoggledown = 'J',
        stogglevm = '<Space>',
        ptoggleitem = 'p',
        ptoggleauto = 'P',
        ptogglemode = 'zp',
        pscrollup = '<C-b>',
        pscrolldown = '<C-f>',
        prevfile = 'gk',
        nextfile = 'gj',
        prevhist = '<S-Tab>',
        nexthist = '<Tab>',
      },
      preview = {
        auto_preview = false,
        should_preview_cb = function(bufnr)
          -- file size greater than 100kb can't be previewed automatically
          local filename = vim.api.nvim_buf_get_name(bufnr)
          local fsize = vim.fn.getfsize(filename)
          if fsize > 100 * 1024 then return false end
          return true
        end,
      },
    },
    config = function(_, opts)
      mines.highlight.plugin('bqf', { { BqfPreviewBorder = { fg = { from = 'Comment' } } } })
      require('bqf').setup(opts)
    end,
  }, -- nvim-bqf
  {
    url = 'https://gitlab.com/yorickpeterse/nvim-pqf',
    config = function() require('pqf').setup() end,
  }, -- nvim-pqf

  -----------------------------------------------------------------------------//
  -- Utilities
  -----------------------------------------------------------------------------//
  {
    'max397574/better-escape.nvim',
    event = { 'InsertEnter' },
    opts = {
      mapping = { 'jk' }, -- a table with mappings to use
      timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
      clear_empty_lines = false, -- clear line after escaping if there is only whitespace
      keys = '<Esc>', -- keys used for escaping, if it is a function will use the result everytime
    },
  }, -- better-escape
  {
    'anuvyklack/vim-smartword',
    enabled = false,
    event = 'VeryLazy',
  }, -- vim-smartword
  {
    'tpope/vim-repeat',
    event = { 'BufReadPost', 'BufNewFile' },
  }, -- vim-repeat
  {
    'mg979/vim-visual-multi',
    keys = {
      { '<c-n>', '<Plug>(VM-Find-Under)' },
      { '<n-n>', '<Plug>(VM-Find-Under)' },
      { '<c-n>', '<Plug>(VM-Find-Subword-Under)', mode = 'x' },
      { '<C-S-A>', '<Plug>(VM-Select-All)', desc = 'visual multi: select all' },
      { '<C-S-A>', '<Plug>(VM-Visual-All)', mode = 'x', desc = 'visual multi: visual all' },
    },
    init = function()
      vim.g.VM_Extend_hl = 'VM_Extend_hi'
      vim.g.VM_Cursor_hl = 'VM_Cursor_hi'
      vim.g.VM_Mono_hl = 'VM_Mono_hi'
      vim.g.VM_Insert_hl = 'VM_Insert_hi'
      vim.g.VM_highlight_matches = ''
      vim.g.VM_show_warnings = 0
      vim.g.VM_silent_exit = 1
      vim.g.VM_default_mappings = 1
    end,
  }, -- vim-visual-multi
  {
    'chrisgrieser/nvim-origami',
    keys = { { '<BS>', function() require('origami').h() end, desc = 'toggle fold' } },
    event = 'BufReadPost',
    opts = {},
  }, -- nvim-origami
  {
    'andrewferrier/debugprint.nvim',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>dp',
        function() return require('debugprint').debugprint { variable = true } end,
        { desc = 'debugprint: cursor', expr = true },
      },
      {
        '<leader>do',
        function() return require('debugprint').debugprint { motion = true } end,
        { desc = 'debugprint: operator', expr = true },
      },
      { '<leader>C', '<Cmd>DeleteDebugPrints<CR>', { desc = 'debugprint: clear all' } },
    },
    opts = { create_keymaps = false },
  }, -- debugprint.nvim
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      local autopairs = require 'nvim-autopairs'
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
      autopairs.setup {
        close_triple_quotes = true,
        check_ts = true,
        fast_wrap = { map = '<m-e>' },
        ts_config = {
          lua = { 'string' },
          dart = { 'string' },
          javascript = { 'template_string' },
        },
      }
    end,
  }, -- nvim-autopairs
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = { { '<leader>u', '<Cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' } },
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_WindowLayout = 3
    end,
  }, -- undotree
  {
    'andymass/vim-matchup',
    enabled = true,
    event = 'BufReadPost',
    init = function()
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end,
  }, -- vim-matchup
  {
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    config = function()
      mines.highlight.plugin('marks', {
        { MarkSignHL = { link = 'Directory' } },
        { MarkSignNumHL = { link = 'Directory' } },
      })
      map('n', '<leader>mb', '<Cmd>MarksQFListBuf<CR>', { desc = 'list buffer' })
      map('n', '<leader>mg', '<Cmd>MarksQFListGlobal<CR>', { desc = 'list global' })
      map('n', '<leader>m0', '<Cmd>BookmarksQFList 0<CR>', { desc = 'list bookmark' })

      require('marks').setup {
        force_write_shada = false, -- This can cause data loss
        excluded_filetypes = { 'NeogitStatus', 'NeogitCommitMessage', 'toggleterm' },
        bookmark_0 = { sign = '⚑', virt_text = '' },
        mappings = {
          annotate = 'm?',
        },
      }
    end,
  }, -- marks.nvim
  {
    'monaqa/dial.nvim',
    keys = {
      { '<c-a>', '<Plug>(dial-increment)', mode = 'n', 'v' },
      { '<c-x>', '<Plug>(dial-decrement)', mode = 'n', 'v' },
      { 'g<c-a>', 'g<Plug>(dial-increment)', mode = 'v' },
      { 'g<c-x>', 'g<Plug>(dial-decrement)', mode = 'v' },
    },
    config = function()
      local augend = require 'dial.augend'
      local config = require 'dial.config'

      local operators = augend.constant.new {
        elements = { '&&', '||' },
        word = false,
        cyclic = true,
      }

      local casing = augend.case.new {
        types = {
          'camelCase',
          'snake_case',
          'PascalCase',
          'SCREAMING_SNAKE_CASE',
        },
        cyclic = true,
      }

      config.augends:register_group {
        -- default augends used when no group name is specified
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias['%Y/%m/%d'],
          -- augend.date.alias['%m/%d/%y'],
          augend.constant.alias.bool,
        },
        casing,
        dep_files = { augend.semver.alias.semver },
      }

      config.augends:on_filetype {
        typescript = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.constant.alias.bool,
          augend.constant.new { elements = { 'let', 'const' } },
          operators,
          casing,
        },
        markdown = { augend.integer.alias.decimal, augend.misc.alias.markdown_header },
        yaml = { augend.integer.alias.decimal, augend.semver.alias.semver },
        toml = { augend.integer.alias.decimal, augend.semver.alias.semver },
      }
    end,
  }, -- dial.nvim
}
