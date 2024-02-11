local fn, api = vim.fn, vim.api
local highlight = mines.highlight
local icons = mines.ui.icons
local autocmd = api.nvim_create_autocmd

local winwidth = 35

-- Toggle width.
local toggle_width = function()
  local max = winwidth * 2
  local cur_width = vim.fn.winwidth(0)
  local half = math.floor((winwidth + (max - winwidth) / 2) + 0.4)
  local new_width = winwidth
  if cur_width == winwidth then
    new_width = half
  elseif cur_width == half then
    new_width = max
  else
    new_width = winwidth
  end
  vim.cmd(new_width .. ' wincmd |')
end

-- Get current opened directory from state.
---@param state table
---@return string
local function get_current_directory(state)
  local node = state.tree:get_node()
  local path = node.path
  if node.type ~= 'directory' or not node:is_expanded() then
    local path_separator = package.config:sub(1, 1)
    path = path:match('(.*)' .. path_separator)
  end
  return path
end

return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  cmd = { 'Neotree' },
  deactivate = function() vim.cmd [[Neotree close]] end,
  keys = {
    {
      '<leader>fe',
      function() require('neo-tree.command').execute { toggle = true, dir = mines.get_root() } end,
      desc = 'NeoTree (root dir)',
    },
    {
      '<leader>fE',
      function() require('neo-tree.command').execute { toggle = true, dir = vim.loop.cwd() } end,
      desc = 'NeoTree (cwd)',
    },
    {
      '<LocalLeader>a',
      function()
        require('neo-tree.command').execute {
          reveal = true,
          toggle = true,
          dir = mines.get_root(),
        }
      end,
      desc = 'NeoTree Reveal',
    },
    { '<LocalLeader>e', '<leader>fe', desc = 'NeoTree (root dir)', remap = true },
    { '<leader>e', '<leader>fe', desc = 'NeoTree (root dir)', remap = true },
    { '<leader>E', '<leader>fE', desc = 'NeoTree (cwd)', remap = true },
  },
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    {
      'ten3roberts/window-picker.nvim',
      name = 'window-picker',
      config = function()
        local picker = require 'window-picker'
        picker.setup()
        picker.pick_window = function()
          return picker.select(
            { hl = 'WindowPicker', prompt = 'Pick window: ' },
            function(winid) return winid or nil end
          )
        end
      end,
    },
  },
  init = function()
    autocmd('BufEnter', {
      desc = 'Load NeoTree if entering a directory',
      callback = function(args)
        if fn.isdirectory(api.nvim_buf_get_name(args.buf)) > 0 then
          require('lazy').load { plugins = { 'neo-tree.nvim' } }
          api.nvim_del_autocmd(args.id)
        end
      end,
    })
  end,
  opts = function()
    local symbols = require('lspkind').symbol_map
    local lsp_kinds = mines.ui.lsp.highlights

    return {
      close_if_last_window = true,
      sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
      source_selector = {
        winbar = mines.ui.winbar.enable,
        -- show_scrolled_off_parent_node = true,
        padding = { left = 1, right = 0 },
        separator_active = '',
        sources = {
          { source = 'filesystem', display_name = '  Files' }, --       
          { source = 'buffers', display_name = '  Buffers' }, --        
          { source = 'git_status', display_name = ' 󰊢 Git' }, -- 󰊢      
        },
      },
      enable_git_status = true,
      enable_normal_mode_for_inputs = true,
      git_status_async = true,
      nesting_rules = {
        ['docker'] = {
          pattern = '^dockerfile$',
          ignore_case = true,
          files = { '.dockerignore', 'docker-compose.*', 'dockerfile*' },
        },
      },
      event_handlers = {
        -- Close neo-tree when opening a file.
        {
          event = 'file_opened',
          handler = function() require('neo-tree.command').execute { action = 'close' } end,
        },
        {
          event = 'neo_tree_buffer_enter',
          handler = function() highlight.set('Cursor', { blend = 100 }) end,
        },
        {
          event = 'neo_tree_popup_buffer_enter',
          handler = function() highlight.set('Cursor', { blend = 0 }) end,
        },
        {
          event = 'neo_tree_buffer_leave',
          handler = function() highlight.set('Cursor', { blend = 0 }) end,
        },
        {
          event = 'neo_tree_popup_buffer_leave',
          handler = function() highlight.set('Cursor', { blend = 100 }) end,
        },
        {
          event = 'neo_tree_window_after_close',
          handler = function() highlight.set('Cursor', { blend = 0 }) end,
        },
      },
      filesystem = {
        hijack_netrw_behavior = 'open_current',
        bind_to_cwd = false,
        cwd_target = {
          sidebar = 'window',
          current = 'window',
        },
        use_libuv_file_watcher = true,
        group_empty_dirs = true,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        filtered_items = {
          visible = false,
          show_hidden_count = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            '.git',
            '.hg',
            '.svc',
            '.DS_Store',
            'thumbs.db',
            '.sass-cache',
            'node_modules',
            '.pytest_cache',
            '.mypy_cache',
            '__pycache__',
            '.stfolder',
            '.stversions',
          },
          never_show = {},
        },
        window = {
          position = 'right',
          mappings = {
            ['d'] = 'noop',
            ['dd'] = 'delete',
            ['c'] = { 'copy', config = { show_path = 'relative' } },
            ['m'] = { 'move', config = { show_path = 'relative' } },
            ['a'] = { 'add', nowait = true, config = { show_path = 'relative' } },
            ['N'] = { 'add_directory', config = { show_path = 'relative' } },
            ['r'] = 'rename',
            ['y'] = 'copy_to_clipboard',
            ['x'] = 'cut_to_clipboard',
            ['P'] = 'paste_from_clipboard',

            ['H'] = 'toggle_hidden',
            ['/'] = 'noop',
            ['g/'] = 'fuzzy_finder',
            ['F'] = 'filter_on_submit',
            ['<C-x>'] = 'clear_filter',
            ['<C-c>'] = 'clear_filter',
            ['<BS>'] = 'navigate_up',
            ['.'] = 'set_root',
            ['[g'] = 'prev_git_modified',
            [']g'] = 'next_git_modified',

            ['gf'] = function(state)
              require('telescope.builtin').find_files {
                cwd = get_current_directory(state),
              }
            end,

            ['gr'] = function(state)
              require('telescope.builtin').live_grep {
                cwd = get_current_directory(state),
              }
            end,
          },
        },
      },
      buffers = {
        bind_to_cwd = false,
        window = {
          mappings = {
            ['<BS>'] = 'navigate_up',
            ['.'] = 'set_root',
            ['dd'] = 'buffer_delete',
            ['<c-x>'] = 'buffer_delete',
          },
        },
      },
      git_status = {
        window = {
          mappings = {
            ['d'] = 'noop',
            ['dd'] = 'delete',
          },
        },
      },
      document_symbols = {
        follow_cursor = true,
      },
      default_component_configs = {
        indent = {
          expander_collapsed = '',
          expander_expanded = '',
          expander_highlight = 'NeoTreeExpander',
        },
        icon = {
          folder_closed = '',
          folder_open = '',
          folder_empty = '',
          folder_empty_open = '',
          default = '',
        },
        name = {
          trailing_slash = true,
          highlight_opened_files = true, -- NeoTreeFileNameOpened
          use_git_status_colors = false,
        },
        document_symbols = {
          follow_cursor = true,
          kinds = vim.iter(symbols):fold({}, function(acc, k, v)
            acc[k] = { icon = v, hl = lsp_kinds[k] }
            return acc
          end),
        },
        modified = { symbol = icons.misc.circle .. ' ' },
        git_status = {
          symbols = {
            added = icons.git.add,
            deleted = icons.git.remove,
            modified = icons.git.mod,
            renamed = icons.git.rename,
            untracked = icons.git.untracked,
            ignored = icons.git.ignored,
            unstaged = icons.git.unstaged,
            staged = icons.git.staged,
            conflict = icons.git.conflict,
          },
        },
        file_size = {
          required_width = 50,
        },
      },
      window = {
        width = winwidth,
        mappings = {
          ['<esc>'] = 'revert_preview',
          ['q'] = 'close_window',
          ['?'] = 'noop',
          ['<Space>'] = 'noop',

          ['g?'] = 'show_help',
          ['<2-LeftMouse>'] = 'open',
          ['<CR>'] = 'open_with_window_picker',
          ['l'] = 'open_drop',
          ['h'] = 'close_node',
          ['C'] = 'close_node',
          ['z'] = 'close_all_nodes',
          ['<C-r>'] = 'refresh',

          ['s'] = 'noop',
          ['sv'] = 'open_split',
          ['sg'] = 'open_vsplit',
          ['st'] = 'open_tabnew',

          ['<S-Tab>'] = 'prev_source',
          ['<Tab>'] = 'next_source',

          ['p'] = { 'toggle_preview', nowait = true, config = { use_float = false } },
          ['w'] = toggle_width,
        },
      },
    }
  end,
  config = function(_, opts)
    highlight.plugin('NeoTree', {
      theme = {
        ['*'] = {
          { NeoTreeNormal = { link = 'PanelBackground' } },
          { NeoTreeNormalNC = { link = 'PanelBackground' } },
          { NeoTreeCursorLine = { link = 'Visual' } },
          { NeoTreeRootName = { underline = true } },
          { NeoTreeStatusLine = { link = 'PanelSt' } },
          { NeoTreeTabActive = { bg = { from = 'PanelBackground' }, bold = true } },
          { NeoTreeTabInactive = { bg = { from = 'PanelDarkBackground', alter = 0.15 }, fg = { from = 'Comment' } } },
          { NeoTreeTabSeparatorActive = { inherit = 'PanelBackground', fg = { from = 'Comment' } } },
          {
            NeoTreeTabSeparatorInactive = {
              inherit = 'NeoTreeTabInactive',
              fg = { from = 'PanelDarkBackground', attr = 'bg' },
            },
          },
        },
        horizon = {
          { NeoTreeWinSeparator = { link = 'WinSeparator' } },
          { NeoTreeTabActive = { link = 'VisibleTab' } },
          { NeoTreeTabSeparatorActive = { link = 'VisibleTab' } },
          { NeoTreeTabInactive = { inherit = 'Comment', italic = false } },
          { NeoTreeTabSeparatorInactive = { bg = 'bg', fg = 'bg' } },
        },
      },
    })

    require('neo-tree').setup(opts)

    vim.api.nvim_create_autocmd('TermClose', {
      pattern = '*lazygit',
      callback = function()
        if package.loaded['neo-tree.sources.git_status'] then require('neo-tree.sources.git_status').refresh() end
      end,
    })
  end,
}
