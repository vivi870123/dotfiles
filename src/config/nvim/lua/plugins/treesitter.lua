return {
  { -- nvim-treesitter-textobjects
    'nvim-treesitter/nvim-treesitter-textobjects',
    init = function()
      local plugin = require('lazy.core.config').spec.plugins['nvim-treesitter']
      local opts = require('lazy.core.plugin').values(plugin, 'opts', false)
      local enabled = false
      if opts.textobjects then
        for _, mod in ipairs { 'move', 'select', 'swap', 'lsp_interop' } do
          if opts.textobjects[mod] and opts.textobjects[mod].enable then
            enabled = true
            break
          end
        end
      end
      if not enabled then require('lazy.core.loader').disable_rtp_plugin 'nvim-treesitter-textobjects' end
    end,
  },
  { -- nvim-treesitter
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'FileType',
    keys = {
      { 'v', desc = 'Increment selection', mode = 'x' },
      { 'V', desc = 'Shrink selection', mode = 'x' },
    },
    main = 'nvim-treesitter.configs',
    opts = function()

      -- stylua: ignore
      local install_list = {
        'bash', 'c', 'cmake', 'cpp', 'css', 'diff', 'dockerfile', 'gitcommit', 'gitignore',
        'graphql', 'html', 'http', 'json', 'json5', 'jsonc', 'lua','luadoc', 'make', 'markdown',
        'markdown_inline', 'ninja',  'php', 'phpdoc', 'python', 'query', 'regex', 'rust', 'sql',
        'toml', 'todotxt', 'tsx', 'typescript', 'vim', 'xml', 'yaml', 'zig'
        -- "comment", -- comments are slowing down TS bigtime, so disable for now
      }

      -- @see: https://github.com/nvim-orgmode/orgmode/issues/481
      local ok, orgmode = pcall(require, 'orgmode')
      if ok then orgmode.setup_ts_grammar() end

      return {
        auto_install = true,
        ensure_installed = install_list,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { 'org', 'php', 'sql' },
        },

        indent = {
          enable = true,
          disable = function(lang, bufnr)
            if lang == 'lua' or lang == 'html' or lang == 'vue' or 'yaml' then -- or lang == "python" then
              return true
            else
              return false
            end
          end,
        },

        -- See: https://github.com/windwp/nvim-ts-autotag
        autotag = {
          enable = true,
          -- Removed markdown due to errors
          filetypes = {
            'glimmer',
            'handlebars',
            'hbs',
            'html',
            'javascript',
            'javascriptreact',
            'jsx',
            'rescript',
            'svelte',
            'tsx',
            'typescript',
            'typescriptreact',
            'vue',
            'xml',
          },
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = false,
            node_incremental = 'v',
            scope_incremental = false,
            node_decremental = 'V',
          },
        },

        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[a'] = '@parameter.inner',
            },
            goto_next_start = {
              [']m'] = '@function.outer',
              [']a'] = '@parameter.inner',
            },
          },
        },

        autopairs = {
          enable = true,
        },

        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = { 'BufWrite', 'CursorHold' },
        },
      }
    end,
  },
}

