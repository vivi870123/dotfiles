local highlight, ui = mines.highlight, mines.ui
local icons, P = ui.icons, ui.palette

local lib = require 'lib.telescope'
local width_tiny = lib.width_tiny
local width_small = lib.width_small
local width_medium = lib.width_medium
local width_large = lib.width_large
local telescope = lib.telescope

local function extensions(name) return require('telescope').extensions[name] end
local function luasnips() extensions('luasnip').luasnip() end
local function notifications() extensions('notify').notify() end
local function pickers() require('telescope.builtin').builtin { include_extensions = true } end

return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  dependencies = {
    { 'jvgrootveld/telescope-zoxide' },
    { 'nvim-telescope/telescope-dap.nvim' },
    { 'benfowler/telescope-luasnip.nvim' },
    { 'folke/todo-comments.nvim' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
    { 'nvim-telescope/telescope-smart-history.nvim', dependencies = { 'kkharji/sqlite.lua' } },
  },
  keys = {
    -- General pickers
    { '<localleader>r', telescope('resume', { initial_mode = 'normal' }), desc = 'Resume last' },
    { '<localleader>R', telescope 'pickers', desc = 'Pickers' },
    { '<localleader>f', telescope 'find_files', desc = 'Find files' },
    { '<leader>.', telescope 'find_files', desc = 'Find files' },
    { '<localleader>g', telescope 'live_grep', desc = 'Grep' },
    { '<localleader>b', telescope('buffers', { show_all_buffers = true }), desc = 'Buffers' },
    { '<leader>,', telescope('buffers', { show_all_buffers = true }), desc = 'Buffers' },
    { '<localleader>h', telescope 'highlights', desc = 'Highlights' },
    { '<localleader>j', telescope 'jumplist', desc = 'Jump list' },
    { '<localleader>m', telescope 'marks', desc = 'Marks' },
    { '<localleader>n', notifications, desc = 'Notifications' },
    { '<localleader>o', telescope 'vim_options', desc = 'Neovim options' },
    { '<localleader>t', telescope 'lsp_dynamic_workspace_symbols', desc = 'Workspace symbols' },
    { '<localleader>v', telescope 'registers', desc = 'Registers' },
    { '<localleader>u', telescope 'spell_suggest', desc = 'Spell suggest' },
    { '<localleader>s', telescope 'persisted', desc = 'Sessions' },
    { '<localleader>x', telescope 'oldfiles', desc = 'Old files' },
    { '<localleader>;', telescope 'command_history', desc = 'Command history' },
    { '<localleader>:', telescope 'commands', desc = 'Commands' },
    { '<localleader>/', telescope 'search_history', desc = 'Search history' },
    { '<localleader>l', luasnips, desc = 'Snippets' },

    { '<leader>sd', telescope('diagnostics', { bufnr = 0 }), desc = 'Document diagnostics' },
    { '<leader>sD', telescope 'diagnostics', desc = 'Workspace diagnostics' },
    { '<leader>sh', telescope 'help_tags', desc = 'Help Pages' },
    { '<leader>sk', telescope 'keymaps', desc = 'Key Maps' },
    { '<leader>sm', telescope 'man_pages', desc = 'Man Pages' },
    { '<leader>sw', telescope 'grep_string', desc = 'Word' },
    { '<leader>sc', telescope 'colorscheme', desc = 'Colorscheme' },

    { 'z=', telescope 'spell_suggest', desc = 'spell suggestions' },

    -- LSP related
    { '<localleader>cd', '<cmd>Telescope lsp_definitions<CR>', desc = 'Definitions' },
    { '<localleader>ci', '<cmd>Telescope lsp_implementations<CR>', desc = 'Implementations' },
    { '<localleader>cr', '<cmd>Telescope lsp_references<CR>', desc = 'References' },
    { '<localleader>ca', '<cmd>Telescope lsp_code_actions<CR>', desc = 'Code actions' },
    { '<localleader>ca', ':Telescope lsp_range_code_actions<CR>', mode = 'x', desc = 'Code actions' },
    {
      '<leader>ss',
      function()
        require('telescope.builtin').lsp_document_symbols {
          symbols = {
            'Class',
            'Function',
            'Method',
            'Constructor',
            'Interface',
            'Module',
            'Struct',
            'Trait',
            'Field',
            'Property',
          },
        }
      end,
      desc = 'Goto Symbol',
    },
    {
      '<leader>sS',
      function()
        require('telescope.builtin').lsp_dynamic_workspace_symbols {
          symbols = {
            'Class',
            'Function',
            'Method',
            'Constructor',
            'Interface',
            'Module',
            'Struct',
            'Trait',
            'Field',
            'Property',
          },
        }
      end,
      desc = 'Goto Symbol (Workspace)',
    },

    -- Git
    { '<leader>gs', telescope 'git_status', desc = 'Git status' },
    { '<leader>gr', telescope 'git_branches', desc = 'Git branches' },
    { '<leader>gl', telescope 'git_commits', desc = 'Git commits' },
    { '<leader>gL', telescope 'git_bcommits', desc = 'Git buffer commits' },
    { '<leader>gS', telescope 'git_stash', desc = 'Git stashes' },
    { '<leader>gc', telescope 'git_bcommits_range', mode = { 'x', 'n' }, desc = 'Git bcommits range' },

    -- Plugins
    {
      '<localleader>z',
      function()
        require('telescope').extensions.zoxide.list {
          layout_config = { width = 0.5, height = 0.6 },
        }
      end,
      desc = 'Zoxide (MRU)',
    },
  },
  config = function(_, opts)
    require('telescope').setup(opts)
    require('telescope').load_extension 'smart_history'
    require('telescope').load_extension 'luasnip'
    require('telescope').load_extension 'zoxide'
    require('telescope').load_extension 'live_grep_args'
    if pcall(require, 'dap') then require('telescope').load_extension 'dap' end
    if pcall(require, 'persisted') then require('telescope').load_extension 'persisted' end
  end,
  opts = function()
    local actions = require 'telescope.actions'
    local themes = require 'telescope.themes'
    local layout_actions = require 'telescope.actions.layout'
    local lga_actions = require 'telescope-live-grep-args.actions'

    highlight.plugin('telescope', {
      theme = {
        ['*'] = {
          { TelescopeBorder = { link = 'PickerBorder' } },
          { TelescopePromptPrefix = { link = 'Statement' } },
          { TelescopeTitle = { inherit = 'Normal', bold = true } },
          { TelescopePromptTitle = { fg = { from = 'Normal' }, bold = true } },
          { TelescopeResultsTitle = { fg = { from = 'Normal' }, bold = true } },
          { TelescopePreviewTitle = { fg = { from = 'Normal' }, bold = true } },
        },
        ['doom-one'] = { { TelescopeMatching = { link = 'Title' } } },
      },
    })

    -- Clone the default Telescope configuration and enable hidden files.
    local has_ripgrep = vim.fn.executable 'rg' == 1
    local vimgrep_args = {
      unpack(require('telescope.config').values.vimgrep_arguments),
    }
    table.insert(vimgrep_args, '--hidden')
    table.insert(vimgrep_args, '--follow')
    table.insert(vimgrep_args, '--no-ignore-vcs')
    table.insert(vimgrep_args, '--glob')
    table.insert(vimgrep_args, '!**/.git/*')

    local find_args = {
      'rg',
      '--vimgrep',
      '--files',
      '--follow',
      '--hidden',
      '--no-ignore-vcs',
      '--smart-case',
      '--glob',
      '!**/.git/*',
    }

    return {
      defaults = {
        borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        winblend = 5,

        sorting_strategy = 'descending',
        cache_picker = { num_pickers = 3 },

        prompt_prefix = ' ' .. icons.misc.telescope .. ' ',
        prompt_title = '',
        results_title = '',
        selection_caret = '▍ ',
        multi_icon = ' ',

        path_display = { 'truncate' },
        file_ignore_patterns = {
          '%.jpg',
          '%.jpeg',
          '%.png',
          '%.otf',
          '%.ttf',
          '%.DS_Store',
          '^.git/',
          'node%_modules/.*',
          '^site-packages/',
          '%.yarn/.*',
        },
        set_env = { COLORTERM = 'truecolor' },
        vimgrep_arguments = has_ripgrep and vimgrep_args or nil,

        layout_strategy = 'horizontal',
        layout_config = {
          height = 0.85,
          prompt_position = 'top',
          bottom_pane = {
            height = 15,
          },
        },

        dynamic_preview_title = true,
        cycle_layout_list = { 'flex', 'horizontal', 'vertical', 'bottom_pane', 'center' },

        history = {
          path = vim.g.data_dir .. '/telescope_history.sqlite3',
        },

        mappings = {
          i = {
            ['<C-x>'] = false,
            ['jk'] = { '<Esc>', type = 'command' },

            ['<Tab>'] = actions.move_selection_worse,
            ['<S-Tab>'] = actions.move_selection_better,
            ['<C-u>'] = actions.results_scrolling_up,
            ['<C-d>'] = actions.results_scrolling_down,

            ['<c-j>'] = actions.move_selection_next,
            ['<c-k>'] = actions.move_selection_previous,

            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<C-w>'] = actions.send_selected_to_qflist,

            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,

            ['<C-b>'] = actions.preview_scrolling_up,
            ['<C-f>'] = actions.preview_scrolling_down,

            ['<esc>'] = actions.close,
            ['<c-c>'] = function() vim.cmd 'stopinsert!' end,

            ['<c-v>'] = actions.select_horizontal,
            ['<c-g>'] = actions.select_vertical,
          },
          n = {
            ['<C-x>'] = false,
            ['<Esc>'] = actions.close,
            ['q'] = actions.close,
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,

            ['<Tab>'] = actions.move_selection_worse,
            ['<S-Tab>'] = actions.move_selection_better,
            ['<C-u>'] = actions.results_scrolling_up,
            ['<C-d>'] = actions.results_scrolling_down,

            ['<C-b>'] = actions.preview_scrolling_up,
            ['<C-f>'] = actions.preview_scrolling_down,

            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,

            ['*'] = actions.toggle_all,
            ['u'] = actions.drop_all,
            ['J'] = actions.toggle_selection + actions.move_selection_next,
            ['K'] = actions.toggle_selection + actions.move_selection_previous,
            [' '] = {
              actions.toggle_selection + actions.move_selection_next,
              type = 'action',
              opts = { nowait = true },
            },

            ['sv'] = actions.select_horizontal,
            ['sg'] = actions.select_vertical,
            ['st'] = actions.select_tab,
            ['<c-v>'] = actions.select_horizontal,
            ['<c-g>'] = actions.select_vertical,
            ['<c-t>'] = actions.select_tab,

            ['gg'] = actions.move_to_top,
            ['G'] = actions.move_to_bottom,

            ['!'] = actions.edit_command_line,

            ['p'] = function()
              local entry = require('telescope.actions.state').get_selected_entry()
              require('rafi.lib.preview').open(entry.path)
            end,
          },
        },
        -- stylua: ignore
      },
      pickers = {
        buffers = {
          sort_lastused = true,
          sort_mru = true,
          previewer = false,
          show_all_buffers = true,
          ignore_current_buffer = true,
          layout_strategy = 'bottom_pane',
          mappings = {
            i = { ['<c-x>'] = actions.delete_buffer },
            n = {
              ['dd'] = actions.delete_buffer,
              ['<c-x>'] = actions.delete_buffer,
            },
          },
        },
        git_files = { layout_strategy = 'bottom_pane', previewer = false },
        find_files = {
          layout_strategy = 'bottom_pane',
          previewer = false,
          hidden = true,
          find_command = has_ripgrep and find_args or nil,
        },
        live_grep = {
          dynamic_preview_title = true,
          file_ignore_patterns = { '.git/', '%.svg', '%.lock' },
          max_results = 2000,
        },
        current_buffer_fuzzy_find = {
          layout_strategy = 'bottom_pane',
          previewer = false,
          shorten_path = false,
        },
        quickfix = { layout_strategy = 'bottom_pane' },
        colorscheme = {
          enable_preview = true,
          layout_config = { preview_width = 0.7 },
        },
        highlights = {
          layout_config = { preview_width = 0.7 },
        },
        vim_options = {
          theme = 'dropdown',
          layout_config = { width = width_medium, height = 0.7 },
        },
        command_history = {
          theme = 'dropdown',
          layout_config = { width = width_medium, height = 0.7 },
        },
        search_history = {
          theme = 'dropdown',
          layout_config = { width = width_small, height = 0.6 },
        },
        spell_suggest = {
          theme = 'cursor',
          layout_config = { width = width_tiny, height = 0.45 },
        },
        registers = {
          theme = 'dropdown',
          layout_config = { width = width_medium, height = 0.45 },
        },
        oldfiles = {
          theme = 'dropdown',
          previewer = false,
          layout_config = { width = width_medium, height = 0.7 },
        },
        lsp_definitions = {
          layout_config = { width = width_large, preview_width = 0.55 },
        },
        lsp_implementations = {
          layout_config = { width = width_large, preview_width = 0.55 },
        },
        lsp_references = {
          layout_config = { width = width_large, preview_width = 0.55 },
        },
        lsp_code_actions = {
          theme = 'cursor',
          previewer = false,
          layout_config = { width = 0.3, height = 0.4 },
        },
        lsp_range_code_actions = {
          theme = 'cursor',
          previewer = false,
          layout_config = { width = 0.3, height = 0.4 },
        },
      },
      extensions = {
        persisted = {
          layout_config = { width = 0.55, height = 0.55 },
        },
        live_grep_args = {
          mappings = { -- extend mappings
            i = {
              ['<C-k>'] = lga_actions.quote_prompt(),
              ['<C-i>'] = lga_actions.quote_prompt { postfix = ' --iglob ' },
            },
          },
        },
        zoxide = {
          prompt_title = '[ Zoxide directories ]',
          mappings = {
            default = {
              action = function(selection) vim.cmd.tcd(selection.path) end,
              after_action = function(selection)
                vim.notify("Current working directory set to '" .. selection.path .. "'", vim.log.levels.INFO)
              end,
            },
          },
        },
      },
    }
  end,
}
