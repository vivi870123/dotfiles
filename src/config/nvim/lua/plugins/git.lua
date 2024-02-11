local wo, cmd, opt_local = vim.wo, vim.cmd, vim.opt_local
local icons, border = mines.ui.icons.separators, mines.ui.current.border

return {
  { -- gitsigns.nvim
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      {
        ']h',
        function()
          if opt_local.diff:get() then
            cmd.normal { bang = true, args = { ']c' } }
          else
            require('gitsigns.actions').next_hunk()
          end
        end,
        desc = 'git: next hunk',
      },
      {
        '[h',
        function()
          if opt_local.diff:get() then
            cmd.normal { bang = true, args = { '[c' } }
          else
            require('gitsigns.actions').prev_hunk()
          end
        end,
        desc = 'git: prev hunk',
      },
      { '=f', '<cmd>Gitsigns preview_hunk<cr>', desc = 'git: open status buffer' },
      { '=s', '<cmd>Gitsigns stage_buffer<cr>', desc = 'git: stage buffer' },
      { '=S', '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>' },
      { 'ih', ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>', mode = { 'o', 'x' } },
      { 'ah', ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>', mode = { 'o', 'x' } },
    },
    opts = {
      signs = {
        add = { text = icons.right_block },
        change = { text = icons.right_block },
        delete = { text = icons.right_block },
        topdelete = { text = icons.right_block },
        changedelete = { text = icons.right_block },
        untracked = { text = icons.light_shade_block },
      },
      word_diff = false,
      numhl = false,
      preview_config = { border = border },
      watch_gitdir = { interval = 1000 },
    },
  },
  { -- neogit
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { 'mg', function() require('neogit').open() end, 'open status buffer' },
    },
    opts = {
      disable_signs = false,
      disable_context_highlighting = false,
      disable_commit_confirmation = false,
      disable_builtin_notifications = true,
      disable_insert_on_commit = false,
      signs = {
        section = { '', '' }, -- "󰁙", "󰁊"
        item = { '▸', '▾' },
        hunk = { '󰐕', '󰍴' },
      },
      integrations = {
        diffview = true,
      },

      _inline2 = true,
      _extmark_signs = true,
      _signs_staged_enable = false,
    },
  }, -- neogit.nvim
  { -- diffview.nvim
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffViewLog' },
    keys = {
      { '<Leader>gv', '<cmd>DiffviewOpen<CR>', desc = 'DiffView' },
      { '<leader>gh', '<Cmd>DiffviewFileHistory<CR>', desc = 'Diff file' },
    },
    opts = function()
      local actions = require 'diffview.actions'
      mines.augroup('Diffview', {
        event = { 'WinEnter', 'BufEnter' },
        pattern = 'diffview:///panels/*',
        command = function()
          opt_local.cursorline = true
          opt_local.winhighlight = 'CursorLine:WildMenu'
        end,
      })

      return {
        default_args = { DiffviewFileHistory = { '%' } },
        hooks = {
          diff_buf_read = function()
            wo.wrap = false
            wo.list = false
            wo.colorcolumn = ''
          end,
        },
        enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
        keymaps = {
          view = {
            { 'n', 'q', '<cmd>DiffviewClose<CR>' },
            { 'n', '<Tab>', actions.select_next_entry },
            { 'n', '<S-Tab>', actions.select_prev_entry },
            { 'n', '<LocalLeader>a', actions.focus_files },
            { 'n', '<LocalLeader>e', actions.toggle_files },
          },
          file_panel = {
            { 'n', 'q', '<cmd>DiffviewClose<CR>' },
            { 'n', 'h', actions.prev_entry },
            { 'n', 'o', actions.focus_entry },
            { 'n', 'gf', actions.goto_file },
            { 'n', 'sg', actions.goto_file_split },
            { 'n', 'st', actions.goto_file_tab },
            { 'n', '<C-r>', actions.refresh_files },
            { 'n', ';e', actions.toggle_files },
          },
          file_history_panel = {
            { 'n', 'q', '<cmd>DiffviewClose<CR>' },
            { 'n', 'o', actions.focus_entry },
            { 'n', 'O', actions.options },
          },
        },
      }
    end,
  }, -- diffview.nvim
}
