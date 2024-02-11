local border, highlight = mines.ui.current.border, mines.highlight
local icon = mines.ui.icons

return {
  { -- lspkind
    'onsails/lspkind.nvim',
  },
  { -- schemastore
    'b0o/schemastore.nvim',
  },
  { -- nvim-lightbulb
    'kosayoda/nvim-lightbulb',
    event = 'LspAttach',
    opts = {
      priority = 40,
      sign = { enabled = false },
      float = {
        enabled = true,
        win_opts = { border = 'none' },
        text = icon.misc.lightbulb,
      },
      autocmd = { enabled = true },
    },
  },
  { -- mason []
    { -- mason.nvim
      'williamboman/mason.nvim',
      cmd = 'Mason',
      build = ':MasonUpdate',
      opts = {
        ensure_installed = {},
        ui = { border = border, height = 0.8 },
      },
      config = function(_, opts)
        ---@param opts MasonSettings | {ensure_installed: string[]}
        require('mason').setup(opts)
        local mr = require 'mason-registry'
        local function ensure_installed()
          for _, tool in ipairs(opts.ensure_installed) do
            local p = mr.get_package(tool)
            if not p:is_installed() then p:install() end
          end
        end
        if mr.refresh then
          mr.refresh(ensure_installed)
        else
          ensure_installed()
        end
      end,
    },
    { -- mason-lspconfig.nvim
      'williamboman/mason-lspconfig.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = {
        'mason.nvim',
        { -- nvim-lspconfig
          'neovim/nvim-lspconfig',
          dependencies = {
            { -- neodev
              'folke/neodev.nvim',
              ft = 'lua',
              opts = { library = { plugins = {} } },
            },
            { -- neoconf
              'folke/neoconf.nvim',
              cmd = 'Neoconf',
              opts = {
                local_settings = '.nvim.json',
                global_settings = 'nvim.json',
              },
            },
          },
          config = function()
            highlight.plugin('lspconfig', { { LspInfoBorder = { link = 'FloatBorder' } } })
            require('lspconfig.ui.windows').default_options.border = border
          end,
        }, -- lspconfig
      },
      opts = {
        automatic_installation = true,
        handlers = {
          function(name)
            local config = require 'servers'(name)
            if config then require('lspconfig')[name].setup(config) end
          end,
        },
      },
    },
  },
  { -- mason-null-ls.mvim
    'jay-babu/mason-null-ls.nvim',
    dependencies = {
      'mason.nvim',
      { -- none-ls
        'nvimtools/none-ls.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
      },
    },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local null_ls = require 'null-ls'

      require('mason-null-ls').setup {
        automatic_setup = true,
        automatic_installation = true,
        ensure_installed = {
          'goimports',
          'luacheck',
          'prettier',
          'shfmt',
          'shellharden',
          'shellcheck',
          'stylua',
        },
        handlers = {
          sql_formatter = function()
            null_ls.register(null_ls.builtins.formatting.sql_formatter.with {
              extra_filetypes = { 'pgsql' },
              args = function(params)
                local config_path = params.cwd .. '/.sql-formatter.json'
                if vim.loop.fs_stat(config_path) then return { '--config', config_path } end
                return { '--language', 'postgresql' }
              end,
            })
          end,
          eslint = function()
            null_ls.register(null_ls.builtins.diagnostics.eslint.with { extra_filetypes = { 'svelte' } })
          end,
        },
      }
      null_ls.setup()
    end,
  },
}
