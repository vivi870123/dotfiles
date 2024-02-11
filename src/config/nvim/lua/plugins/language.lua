local sys = require 'sys'

return {
  { -- package-info.nvim
    'vuki656/package-info.nvim',
    event = 'BufRead package.json',
    dependencies = 'MunifTanjim/nui.nvim',
    opts = {},
  },
  { -- vim-kitty
    'fladson/vim-kitty',
    lazy = false,
  },
  { -- vim-log-highlighting
    'mtdl9/vim-log-highlighting',
    lazy = false,
  },
  { -- pgsql.vim
    'lifepillar/pgsql.vim',
    lazy = false,
  },
  { -- vim-blade
    'jwalton512/vim-blade',
    enabled = false,
    ft = 'blade',
    opts = { custom_directives = { 'routes', 'vite', 'intertiaHead', 'interia' } },
  },

  -- HTTP
  { -- rest.nvim
    'NTBBloodbath/rest.nvim',
    ft = 'http',
    opts = {
      result_split_horizontal = false,
      skip_ssl_verification = false,
      encode_url = false,
      highlight = { enabled = true, timeout = 150 },
      result = {
        show_url = true,
        show_http_info = true,
        show_headers = true,
      },
      jump_to_request = false,
      env_file = '.env',
      custom_dynamic_variables = {},
      yank_dry_run = true,
    },
    config = function(_, opts)
      require('rest-nvim').setup(opts)

      mines.augroup('RestAutocommand', {
        event = 'FileType',
        pattern = 'http',
        command = function()
          local rest = require 'rest-nvim'
          local bufnr = tonumber(vim.fn.expand '<abuf>', 10)
          map('n', '<leader>hn', rest.run, { desc = 'rest: run request', buffer = bufnr })
          map('n', '<leader>hl', rest.last, { desc = 'rest: last request', buffer = bufnr })
          map('n', '<leader>hp', function() rest.run(true) end, { desc = 'rest: run with preview', buffer = bufnr })
        end,
      })
    end,
  },

  -- Markdown
  { -- markdown-preview.nvim
    'iamcco/markdown-preview.nvim',
    ft = 'markdown',
    build = function() vim.fn['mkdp#util#install']() end,
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 0
    end,
  },
  { -- glow.nvim
    'ellisonleao/glow.nvim',
    event = 'VeryLazy',
    ft = 'markdown',
    cmd = 'Glow',
    init = function()
      mines.augroup('GlowAutocomands', {
        event = 'FileType',
        pattern = 'markdown',
        command = function() map('i', '<leader>lp', '<cmd>Glow<cr>', { desc = 'Preview', buffer = true }) end,
      })
    end,
    opts = {
      install_path = sys.home .. '/.local/bin', -- default path for installing glow binary
    },
  },
  { -- nvim-FeMaco
    'AckslD/nvim-FeMaco.lua',
    cmd = 'FeMaco',
    ft = 'markdown',
    init = function()
      mines.augroup('FamacoAutocommands', {
        event = 'FileType',
        pattern = 'markdown',
        command = function()
          map('n', '<leader>ec', '<cmd>FeMaco<cr>', { desc = 'Edit codeblock', buffer = true })
          map('i', '<c-l>', '<cmd>FeMaco<cr>', { desc = 'Edit codeblock', buffer = true })
        end,
      })
    end,
    opts = {
      post_open_float = function(_)
        vim.wo.signcolumn = 'no'
        map('n', '<esc>', '<cmd>q<cr>', { buffer = true })
      end,
    },
  },
  { -- peek.nvim
    'toppair/peek.nvim',
    event = 'VeryLazy',
    build = { 'deno task --quiet build:fast' },
    init = function()
      mines.augroup('PeekAutocommands', {
        event = 'FileType',
        pattern = 'markdown',
        command = function()
          map('n', '<Leader>eP', function()
            local peek = require 'peek'
            if peek.is_open() then
              peek.close()
            else
              peek.open()
            end
          end, { desc = 'Live preview', buffer = true })
        end,
      })
    end,
    opts = {
      app = 'browser',
    },
  },

  -- Typescript
  { -- typescript-tools.nvim
    'pmizio/typescript-tools.nvim',
    ft = { 'typescript', 'typescriptreact' },
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      tsserver_file_preferences = {
        includeInlayParameterNameHints = 'literal',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
  { -- tsc.nvim
    'dmmulroy/tsc.nvim',
    cmd = 'TSC',
    opts = {},
  },
}
