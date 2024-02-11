return {
  'echasnovski/mini.basics',
  event = 'VeryLazy',
  opts = {
    options = {
      basic = false,

      -- Extra UI features ('winblend', 'cmdheight=0', ...)
      extra_ui = true,

      -- Presets for window borders ('single', 'double', ...)
      win_borders = 'default',
    },

    mappings = {
      ---  |Keys   |     Modes              |                  Description                  |
      ---  |-------|------------------------|-----------------------------------------------|
      ---  | j     | Normal, Visual         | Move down by visible lines with no [count]    |
      ---  | k     | Normal, Visual         | Move up by visible lines with no [count]      |
      ---  | go    | Normal                 | Add [count] empty lines after cursor          |
      ---  | gO    | Normal                 | Add [count] empty lines before cursor         |
      ---  | gy    | Normal, Visual         | Copy to system clipboard                      |
      ---  | gp    | Normal, Visual         | Paste from system clipboard                   |
      ---  | gV    | Normal                 | Visually select latest changed or yanked text |
      ---  | g/    | Visual                 | Search inside current visual selection        |
      ---  | *     | Visual                 | Search forward for current visual selection   |
      ---  | #     | Visual                 | Search backward for current visual selection  |
      ---  | <C-s> | Normal, Visual, Insert | Save and go to Normal mode                    |
      basic = true,

      -- Window navigation with <C-hjkl>, resize with <C-arrow>
      windows = true,

      -- Move cursor in Insert, Command, and Terminal mode with <M-hjkl>
      move_with_alt = false,
    },

    -- Autocommands. Set to `false` to disable
    autocommands = {
      -- Basic autocommands (highlight on yank, start Insert in terminal, ...)
      basic = true,

      -- Set 'relativenumber' only in linewise and blockwise Visual mode
      relnum_in_visual_mode = false,
    },

    -- Whether to disable showing non-error feedback
    silent = true,
  },
}
