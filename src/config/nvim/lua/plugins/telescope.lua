local highlight, ui = mines.highlight, mines.ui
local icons = ui.icons
local P = ui.palette
local sys = require 'sys'

-- Helpers
-- A helper function to limit the size of a telescope window to fit the maximum available
-- space on the screen. This is useful for dropdowns e.g. the cursor or dropdown theme
local function fit_to_available_height(self, _, max_lines)
  local results, PADDING = #self.finder.results, 4 -- this represents the size of the telescope window
  local LIMIT = math.floor(max_lines / 2)
  return (results <= (LIMIT - PADDING) and results + PADDING or LIMIT)
end

---@param opts table
---@return table
local function ivy(opts)
  return require('telescope.themes').get_ivy(vim.tbl_extend('keep', opts or {}, {
    previewer = false,
    layout_config = { bottom_pane = { height = 12 } },
  }))
end

---@param opts table
---@return table
local function cursor(opts)
  return require('telescope.themes').get_cursor(vim.tbl_extend('keep', opts or {}, {
    layout_config = { width = 0.4, height = fit_to_available_height },
  }))
end

---@param opts table
---@return table
local function dropdown(opts)
  return require('telescope.themes').get_dropdown(vim.tbl_extend('keep', opts or {}, {
    borderchars = {
      { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
      results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    },
  }))
end

mines.telescope = {
  cursor = cursor,
  dropdown = dropdown,
  ivy = ivy,
  adaptive_dropdown = function(_) return dropdown { height = fit_to_available_height } end,
}

local function extensions(name) return require('telescope').extensions[name] end
local function live_grep(opts) return extensions('menufacture').live_grep(opts) end
local function find_files(opts) return extensions('menufacture').find_files(opts) end

local function frecency() extensions('frecency').frecency(dropdown { previewer = false }) end
local function luasnips() extensions('luasnip').luasnip(dropdown()) end

local function dotfiles()
  find_files {
    prompt_title = 'dotfiles',
    cwd = sys.dotfiles,
    file_ignore_patterns = {
      '.git/.*',
      'zsh/plugins/.*',
      'src/share/themes',
      'src/share/fonts',
    },
  }
end

local function stopinsert(callback)
  return function(prompt_bufnr)
    vim.cmd.stopinsert()
    vim.schedule(function() callback(prompt_bufnr) end)
  end
end

local function b(picker)
  return function() require('telescope.builtin')[picker]() end
end

return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  enabled = true,
  keys = {
    { '<localleader>D', dotfiles, desc = 'find files' },
    { '<leader>.', find_files, desc = 'find files' },
    { '<leader>,', b 'buffers', desc = 'buffers' },
    { '<localleader>;', b 'current_buffer_fuzzy_find', desc = 'search buffer' },
    { '<localleader>b', b 'buffers', desc = 'buffers' },
    { '<localleader>s', luasnips, desc = 'luasnip: available snippets' },
    { '<localleader>H', b 'highlights', desc = 'highlights' },
    { '<localleader>h', frecency, desc = 'Most (f)recently used files' },
    { '<localleader>g', live_grep, desc = 'live grep' },
    { '<leader>?', b 'help_tags', desc = 'help' },
    { '<localleader>f', find_files, desc = 'find files' },
    { '<localleader>p', b 'registers', desc = 'registers' },
    { '<localleader>r', b 'resume', desc = 'resume last picker' },
    { 'z=', b 'spell_suggest', desc = 'spell suggest' },
    { '<c-q>', b 'quickfix', desc = 'quickfix' },
  },
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'benfowler/telescope-luasnip.nvim' },
    { 'molecule-man/telescope-menufacture' },
    { 'natecraddock/telescope-zf-native.nvim' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
    { 'nvim-telescope/telescope-smart-history.nvim', dependencies = { { 'kkharji/sqlite.lua' } } },
    { 'nvim-telescope/telescope-frecency.nvim', dependencies = { { 'kkharji/sqlite.lua' } } },
  },
  opts = function()
    local actions = require 'telescope.actions'
    local lga_actions = require 'telescope-live-grep-args.actions'

    return {
      defaults = {
        dynamic_preview_title = true,
        prompt_title = '',
        results_title = '',
        selection_caret = icons.misc.chevron_right .. ' ',
        prompt_prefix = ' ' .. icons.misc.telescope .. ' ',
        layout_config = { prompt_position = 'bottom' },
        mappings = {
          i = {
            ['<C-x>'] = false,
            ['jk'] = { '<Esc>', type = 'command' },
            ['<Tab>'] = actions.move_selection_next,
            ['<S-Tab>'] = actions.move_selection_previous,
            ['<CR>'] = stopinsert(actions.select_default),
            ['<c-j>'] = actions.move_selection_next,
            ['<c-k>'] = actions.move_selection_previous,
            ['<esc>'] = actions.close,
            ['<C-w>'] = actions.send_selected_to_qflist,
            ['<c-c>'] = function() vim.cmd 'stopinsert!' end,
            ['<c-v>'] = actions.select_horizontal,
            ['<c-g>'] = actions.select_vertical,
            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,
            ['<C-b>'] = actions.preview_scrolling_up,
            ['<C-f>'] = actions.preview_scrolling_down,
            ['<c-/>'] = actions.which_key,
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
          },
          n = {
            ['<C-w>'] = actions.send_selected_to_qflist,
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
          },
        },
        history = { path = sys.data .. '/telescope_history.sqlite3' },
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
      },
      extensions = {
        persisted = ivy(),
        menufacture = {
          mappings = {
            main_menu = { [{ 'i', 'n' }] = '<C-;>' },
          },
        },
        frecency = {
          default_workspace = 'CWD',
          show_unindexed = false, -- Show all files or only those that have been indexed
          ignore_patterns = { '*.git/*', '*/tmp/*', '*node_modules/*', '*vendor/*' },
          workspaces = { conf = vim.env.DOTFILES, project = vim.env.PROJECTS_DIR },
        },
        live_grep_args = {
          mappings = { -- extend mappings
            i = {
              ['<C-k>'] = lga_actions.quote_prompt(),
              ['<C-i>'] = lga_actions.quote_prompt { postfix = ' --iglob ' },
            },
          },
        },
        ['zf-native'] = {
          generic = { enable = true, match_filename = true },
        },
      },
      pickers = {
        buffers = mines.telescope.ivy {
          ignore_current_buffer = true,
          mappings = {
            i = { ['<c-x>'] = require('telescope.actions').delete_buffer },
            n = { ['<c-x>'] = require('telescope.actions').delete_buffer },
          },
        },
        colorscheme = {
          enable_preview = false,
          theme = 'cursor',
          layout_config = { width = 0.45, height = 0.8 },
        },
        current_buffer_fuzzy_find = mines.telescope.ivy {
          shorten_path = false,
        },
        find_files = mines.telescope.ivy {
          hidden = true,
          find_command = { 'rg', '--smart-case', '--hidden', '--no-ignore-vcs', '--glob', '!.git', '--files' },
        },
        git_files = mines.telescope.ivy {},
        help_tags = mines.telescope.ivy {
          previewer = true,
        },
        live_grep = mines.telescope.ivy {
          file_ignore_patterns = { '.git/', '%.svg', '%.lock' },
          max_results = 2000,
        },
        oldfiles = mines.telescope.ivy {},
        quickfix = mines.telescope.ivy {},
        reloader = mines.telescope.dropdown {},
        search_history = mines.telescope.ivy {},
        spell_suggest = mines.telescope.cursor {
          layout_config = { width = 0.15, height = 0.40 },
        },
      },
    }
  end,
  config = function(_, opts)
    highlight.plugin('telescope', {
      theme = {
        ['*'] = {
          { TelescopeBorder = { fg = P.grey } },
          { TelescopePromptPrefix = { link = 'Statement' } },
          { TelescopeTitle = { inherit = 'Normal', bold = true } },
          { TelescopePromptTitle = { fg = { from = 'Normal' }, bold = true } },
          { TelescopeResultsTitle = { fg = { from = 'Normal' }, bold = true } },
          { TelescopePreviewTitle = { fg = { from = 'Normal' }, bold = true } },
        },
      },
    })

    require('telescope').setup(opts)

    -- Extensions (sometimes need to be explicitly loaded after telescope is setup)

    if pcall(require, 'noice') then require('telescope').load_extension 'noice' end
    if pcall(require, 'frecency') then require('telescope').load_extension 'frecency' end
    if pcall(require, 'menufacture') then require('telescope').load_extension 'menufacture' end
    if pcall(require, 'zf-native') then require('telescope').load_extension 'zf-native' end
    if pcall(require, 'live_grep_args') then require('telescope').load_extension 'live_grep_args' end
    if pcall(require, 'sqlite') then require('telescope').load_extension 'smart_history' end
    if pcall(require, 'luasnip') then require('telescope').load_extension 'luasnip' end
    if pcall(require, 'persisted') then require('telescope').load_extension 'persisted' end
  end,
}
