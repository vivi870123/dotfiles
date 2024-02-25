local api, fn, k = vim.api, vim.fn, vim.keycode
local ui, highlight = mines.ui, mines.highlight
local ellipsis, border = ui.icons.misc.ellipsis, ui.current.border

return {
  { -- neogen
    'danymat/neogen',
    keys = { { '<leader>dg', '<cmd>Neogen<cr>', desc = 'Neogen Comment' } },
    opts = { snippet_engine = 'luasnip', input_after_comment = true },
  },
  { -- codeium.vim
    'Exafunction/codeium.vim',
    event = 'InsertEnter',
    init = function()
      vim.g.codeium_filetypes = {
        TelescopePrompt = false,
        ['neo-tree-popup'] = false,
        ['dap-repl'] = false,
      }
    end,
    config = function()
      local expr = { expr = true }

      highlight.plugin('codeium', {
        { CodeiumSuggestion = { link = 'Comment' } },
      })

      -- Change '<C-g>' here to any keycode you like.
      map('i', '<C-g>', function() return fn['codeium#Accept']() end, expr)
      map('i', '<c-;>', function() return fn['codeium#CycleCompletions'](1) end, expr)
      map('i', '<c-,>', function() return fn['codeium#CycleCompletions'](-1) end, expr)
      map('i', '<c-z>', function() return fn['codeium#Clear']() end, expr)
      map('i', '<C-space>', function() return fn['codeium#Complete']() end, expr)
    end,
  },
  { -- nvim-cmp
    'hrsh7th/nvim-cmp',
    -- event = 'VeryLazy',
    event = { "CmdlineEnter", "InsertEnter" },
    dependencies = {
      { 'danymat/neogen' },
      { 'Exafunction/codeium.vim' },
      { 'onsails/lspkind.nvim' },
      { "hrsh7th/cmp-calc" },
      { 'hrsh7th/cmp-nvim-lsp' },
      { "hrsh7th/cmp-cmdline" },
      { 'FelipeLema/cmp-async-path' },
      { 'hrsh7th/cmp-buffer' },
      { 'lukas-reineke/cmp-rg' },
      { 'saadparwaiz1/cmp_luasnip', dependencies = { 'LuaSnip' } },
      { 'roobert/tailwindcss-colorizer-cmp.nvim', ft = { 'css', 'scss', 'jsx', 'tsx' } },
      { 'petertriho/cmp-git', opts = { filetypes = { 'gitcommit', 'NeogitCommitMessage' } } },
      { 'abecodes/tabout.nvim', opts = { ignore_beginning = false, completion = false } },
    },
    opts = function()
      local cmp = require 'cmp'
      local neogen = require 'neogen'
      local lspkind = require 'lspkind'

      local MIN_MENU_WIDTH, MAX_MENU_WIDTH = 25, math.min(50, math.floor(vim.o.columns * 0.5))
      local MAX_INDEX_FILE_SIZE = 4000

      -- Helpers --
      local function shift_tab(fallback)
        local luasnip = require 'luasnip'
        if not cmp.visible() then return fallback() end

        if luasnip.jumpable(-1) then luasnip.jump(-1) end
        if neogen.jumpable(-1) then fn.feedkeys(k "<cmd>lua require('neogen').jump_prev()<CR>", '') end
      end
      local function tab(fallback) -- make TAB behave like Android Studio
        local luasnip = require 'luasnip'
        if not cmp.visible() then return fallback() end
        if not cmp.get_selected_entry() then return cmp.select_next_item { behavior = cmp.SelectBehavior.Select } end
        if neogen.jumpable() then fn.feedkeys(k "<cmd>lua require('neogen').jump_next()<CR>", '') end
        if luasnip.expand_or_jumpable() then return luasnip.expand_or_jump() end
        cmp.confirm()
      end
      return {
        snippet = {
          expand = function(args) require('luasnip').lsp_expand(args.body) end,
        },
        completion = {
          autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged },
          completeopt = 'menu,menuone,noselect',
        },
        window = {
          completion = cmp.config.window.bordered {
            scrollbar = false,
            border = 'none',
            winhighlight = 'NormalFloat:Pmenu,CursorLine:PmenuSel,FloatBorder:FloatBorder',
          },
          documentation = cmp.config.window.bordered {
            border = border,
            winhighlight = 'FloatBorder:FloatBorder',
          },
        },
        mapping = {
          ['<c-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i' }),
          ['<c-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i' }),
          ['<C-c>'] = function(fallback)
            cmp.close()
            fallback()
          end,
          ['<c-space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm { select = false },
          ['<tab>'] = cmp.mapping(tab, { 'i', 's' }),
          ['<s-tab>'] = cmp.mapping(shift_tab, { 'i', 's' }),
          ['<c-e>'] = cmp.mapping.abort(),
          ['<c-x>'] = cmp.mapping.abort(),
          ['<c-j>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
          ['<c-k>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
          ['<c-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
          ['<c-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
          ["<down>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
          ["<up>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
        },
        formatting = {
          deprecated = true,
          fields = { 'kind', 'abbr', 'menu' },
          format = lspkind.cmp_format {
            mode = 'symbol',
            maxwidth = MAX_MENU_WIDTH,
            ellipsis_char = ellipsis,
            before = function(_, vim_item)
              local label, length = vim_item.abbr, api.nvim_strwidth(vim_item.abbr)
              if length < MIN_MENU_WIDTH then vim_item.abbr = label .. string.rep(' ', MIN_MENU_WIDTH - length) end
              return vim_item
            end,
            menu = {
              nvim_lsp = '[LSP]',
              nvim_lua = '[Lua]',
              emoji = '[EMOJI]',
              calc = '[CALC]',
              async_path = '[Path]',
              luasnip = '[SN]',
              dictionary = '[D]',
              buffer = '[B]',
              spell = '[SP]',
              orgmode = '[Org]',
              norg = '[Norg]',
              neorg = '[N]',
              rg = '[Rg]',
              git = '[Git]',
            },
          },
        },
        sources = cmp.config.sources {
          { name = 'luasnip', option = { use_show_condition = false } },
          { name = 'nvim_lsp', group_index = 2 },
          { name = 'async_path', group_index = 2, max_item_count = 10 },
          {
            name = 'buffer',
            group_index = 3,
            max_item_count = 2,
            keyword_length = 3,
            options = {
              get_bufnrs = function()
                local bufs = {}
                for _, bufnr in ipairs(api.nvim_list_bufs()) do
                  -- Don't index giant files
                  if api.nvim_buf_is_loaded(bufnr) and api.nvim_buf_line_count(bufnr) < MAX_INDEX_FILE_SIZE then
                    table.insert(bufs, bufnr)
                  end
                end
                return bufs
              end,
            },
          },
          {
            name = 'rg',
            group_index = 3,
            keyword_length = 4,
            max_item_count = 10,
            entry_filter = function(entry, _)
              return not (entry.exact and string.len(entry.completion_item.label) < 4)
            end,
            option = {
              additional_arguments = "--max-depth 4 --one-file-system --smart-case",
            },
          },
          { name = 'spell', keyword_length = 4, group_index = 3 },
          { name = "calc" },
        },
      }
    end,
    config = function(_, opts)
      highlight.plugin('Cmp', {
        { CmpItemKindVariable = { link = 'Variable' } },
        { CmpItemAbbrMatchFuzzy = { inherit = 'CmpItemAbbrMatch', italic = true } },
        { CmpItemAbbrDeprecated = { strikethrough = true, inherit = 'Comment' } },
        { CmpItemMenu = { inherit = 'Comment', italic = true } },
      })

      local cmp = require('cmp')

      cmp.setup(opts)
      cmp.setup.filetype({ 'dap-repl', 'dapui_watches' }, { sources = { { name = 'dap' } } })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources {
          { name = "buffer" },
        },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources {
          { name = "async_path" },
          { name = "cmdline" },
        },
      })
    end,
  },
  { -- Luasnip
    'L3MON4D3/LuaSnip',
    event = 'InsertEnter',
    version = 'v2.*',
    dependencies = { 'rafamadriz/friendly-snippets' },
    build = 'make install_jsregexp',
    keys = function()
      local ls = require 'luasnip'
      return {
        {
          '<c-o>',
          function()
            if ls.choice_active() then ls.change_choice(1) end
          end,
          desc = 'Neogen Comment',
          mode = { 's', 'i' },
        },
        {
          '<c-l>',
          function() ls.expand_or_jump() end,
          mode = { 's', 'i' },
        },
        {
          '<c-j>',
          function()
            if not ls.expand_or_jumpable() then return '<Tab>' end
            ls.expand_or_jump()
          end,
          expr = true,
          mode = { 's', 'i' },
        },
        {
          '<c-k>',
          function()
            if not ls.jumpable(-1) then return '<S-Tab>' end
            ls.jump(-1)
          end,
          expr = true,
          mode = { 's', 'i' },
        },
      }
    end,
    opts = function()
      local ls = require 'luasnip'
      local types = require 'luasnip.util.types'
      local extras = require 'luasnip.extras'
      local fmt = require('luasnip.extras.fmt').fmt

      return {
        -- Don't store snippet history for less overhead
        history = false,
        region_check_events = 'CursorMoved,CursorHold,InsertEnter',
        delete_check_events = { 'TextChanged', 'InsertLeave' },
        ext_opts = {
          [types.choiceNode] = { active = { hl_mode = 'combine', virt_text = { { '●', 'Operator' } } } },
          [types.insertNode] = { active = { hl_mode = 'combine', virt_text = { { '●', 'Type' } } } },
        },
        enable_autosnippets = true,
        snip_env = {
          fmt = fmt,
          m = extras.match,
          t = ls.text_node,
          f = ls.function_node,
          c = ls.choice_node,
          d = ls.dynamic_node,
          i = ls.insert_node,
          l = extras.lamda,
          sn = ls.snippet_node,
          rep = extras.rep,
          snippet = ls.snippet,
        },
        ft_func = function() return vim.split(vim.bo.filetype, '.', { plain = true }) end,
      }
    end,
    config = function(_, opts)
      local ls = require 'luasnip'
      ls.setup(opts)
      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_lua').load { paths = './snippets' }

      mines.command('SnippetEdit', function() require('luasnip.loaders').edit_snippet_files() end)
      mines.command('SnippetUnlink', function() vim.cmd.LuaSnipUnlinkCurrent() end)

      ls.filetype_extend('typescriptreact', { 'javascript', 'typescript' })
      ls.filetype_extend('NeogitCommitMessage', { 'gitcommit' })

      mines.augroup('SnippetsAutoCommands', {
        event = 'ModeChanged',
        pattern = '[is]:n',
        command = function()
          if ls.in_snippet() then return vim.diagnostic.enable() end
        end,
      }, {
        event = 'ModeChanged',
        pattern = '*:s',
        command = function()
          if ls.in_snippet() then return vim.diagnostic.disable() end
        end,
      })
    end,
  },
}
