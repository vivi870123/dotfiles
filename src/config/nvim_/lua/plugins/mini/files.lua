return {
  'echasnovski/mini.files',
  event = 'BufEnter',
  keys = {
    {
      '<localleader>e',
      function() require('mini.files').open(vim.api.nvim_buf_get_name(0), true) end,
      desc = 'Open mini.files (directory of current file)',
    },
    {
      '<localleader>a',
      function() require('mini.files').open(vim.loop.cwd(), true) end,
      desc = 'Open mini.files (cwd)',
    },
  },
  config = function()
    -- * `MiniFilesBorder` - border of regular windows.
    -- * `MiniFilesBorderModified` - border of windows showing modified buffer.
    -- * `MiniFilesDirectory` - text and icon representing directory.
    -- * `MiniFilesFile` - text representing file.
    -- * `MiniFilesNormal` - basic foreground/background highlighting.
    -- * `MiniFilesTitle` - title of regular windows.
    -- * `MiniFilesTitleFocused` - title of focused window.
    mines.highlight.plugin('NeoTree', {
      theme = {
        ['*'] = {
          { MiniFilesBorder = { link = 'FloatBorder' } },
        },
      },
    })

    require('mini.files').setup {
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 30,
      },
      options = {
        -- Whether to use for editing directories
        -- Disabled by default in LazyVim because neo-tree is used for that
        use_as_default_explorer = true,
      },
      -- Module mappings created only inside explorer.
      -- Use `''` (empty string) to not create one.
      mappings = {
        go_in_plus = '',
        go_out_plus = '',
      },
    }

    local show_dotfiles = true
    local filter_show = function() return true end
    local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, '.') end
    local toggle_dotfiles = function()
      show_dotfiles = not show_dotfiles
      local new_filter = show_dotfiles and filter_show or filter_hide
      require('mini.files').refresh { content = { filter = new_filter } }
    end

    -- Set buffer specific maps in minifiles:
    mines.augroup('MiniFiles', {
      event = 'User',
      pattern = 'MiniFilesBufferCreate',
      command = function(args)
        local buf_id = args.data.buf_id
        map('n', 'gf', '', { buffer = buf_id })
        map('n', 'g.', toggle_dotfiles, { buffer = buf_id })
        map('n', '<C-P>', '<C-P>', { buffer = buf_id }) -- nmap <buffer> <C-P> <C-P>
        map('n', '<Esc>', '<cmd>lua MiniFiles.close()<cr>', { buffer = buf_id })
        map('n', '<C-O>', function()
          local fs_info = require('mini.files').get_fs_entry(buf_id)
          vim.fn.system { 'xdg-open', fs_info.path }
        end, { buffer = buf_id })
      end,
    })

    mines.augroup('MiniFiles', {
      event = 'User',
      pattern = 'MiniFilesActionRename',
      command = function(args) require('lazyvim.util').lsp.on_rename(args.data.from, args.data.to) end,
    })
  end,
}
