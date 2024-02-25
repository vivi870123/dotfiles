return {
  'echasnovski/mini.basics',
  event = 'VeryLazy',
  opts = {
    options = {
      basic = false,
      extra_ui = true, -- Extra UI features ('winblend', 'cmdheight=0', ...)
      win_borders = 'default', -- Presets for window borders ('single', 'double', ...)
    },
    mappings = {
      basic = true,
      windows = true, -- Window navigation with <C-hjkl>, resize with <C-arrow>
      move_with_alt = false, -- Move cursor in Insert, Command, and Terminal mode with <M-hjkl>
    },
    -- Autocommands. Set to `false` to disable
    autocommands = {
      basic = true, -- Basic autocommands (highlight on yank, start Insert in terminal, ...)
      relnum_in_visual_mode = false, -- Set 'relativenumber' only in linewise and blockwise Visual mode
    },
    silent = true, -- Whether to disable showing non-error feedback
  },
}
