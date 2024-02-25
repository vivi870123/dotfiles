local function map_split(buf_id, lhs, direction)
  local minifiles = require 'mini.files'

  local function rhs()
    local window = minifiles.get_target_window()

    -- Noop if the explorer isn't open or the cursor is on a directory.
    if window == nil or minifiles.get_fs_entry().fs_type == 'directory' then return end

    -- Make a new window and set it as target.
    local new_target_window
    vim.api.nvim_win_call(window, function()
      vim.cmd(direction .. ' split')
      new_target_window = vim.api.nvim_get_current_win()
    end)

    minifiles.set_target_window(new_target_window)
    -- Go in and close the explorer.
    minifiles.go_in()
    minifiles.close()
  end

  map('n', lhs, rhs, { buffer = buf_id, desc = 'Split ' .. string.sub(direction, 12) })
end

return {
  'echasnovski/mini.files',
  lazy = false,
  keys = function()
    local function open_cwd()
      local bufname = vim.api.nvim_buf_get_name(0)
      local path = vim.fn.fnamemodify(bufname, ':p')

      -- Noop if the buffer isn't valid.
      if path and vim.uv.fs_stat(path) then require('mini.files').open(bufname, false) end
    end

    return {
      { '<localleader>e', open_cwd, desc = 'File explorer (cwd)' },
      { '<localleader>a', function() require('mini.files').open(mines.get_root()) end, desc = 'File explorer' },
      { 'g-', open_cwd, desc = 'File explorer (cwd)' },
    }
  end,
  init = function()
    if vim.fn.argc() == 1 then
      local argv = vim.fn.argv(0)
      ---@diagnostic disable-next-line: param-type-mismatch
      local stat = vim.loop.fs_stat(argv)
      if stat and stat.type == 'directory' then
        vim.fn.chdir(argv)
        vim.cmd 'bd'
      end
    end
  end,
  opts = {
    mappings = {
      go_in_plus = '<CR>',
      go_out_plus = 'H',
      show_help = 'g?',
    },
    content = {
      filter = function(entry) return entry.fs_type ~= 'file' or entry.name ~= '.DS_Store' end,

      sort = function(entries)
        local function compare_alphanumerically(e1, e2)
          -- Put directories first.
          if e1.is_dir and not e2.is_dir then return true end
          if not e1.is_dir and e2.is_dir then return false end
          -- Order numerically based on digits if the text before them is equal.
          if e1.pre_digits == e2.pre_digits and e1.digits ~= nil and e2.digits ~= nil then
            return e1.digits < e2.digits
          end
          -- Otherwise order alphabetically ignoring case.
          return e1.lower_name < e2.lower_name
        end

        local sorted = vim.tbl_map(function(entry)
          local pre_digits, digits = entry.name:match '^(%D*)(%d+)'
          if digits ~= nil then digits = tonumber(digits) end

          return {
            fs_type = entry.fs_type,
            name = entry.name,
            path = entry.path,
            lower_name = entry.name:lower(),
            is_dir = entry.fs_type == 'directory',
            pre_digits = pre_digits,
            digits = digits,
          }
        end, entries)
        table.sort(sorted, compare_alphanumerically)
        -- Keep only the necessary fields.
        return vim.tbl_map(function(x) return { name = x.name, fs_type = x.fs_type, path = x.path } end, sorted)
      end,
    },
    windows = { width_nofocus = 25 },
    -- Move stuff to the minifiles trash instead of it being gone forever.
    options = {
      permanent_delete = false,
      use_as_default_explorer = true,
    },
  },
  config = function(_, opts)
    local minifiles = require 'mini.files'
    minifiles.setup(opts)

    mines.command('Files', function(data)
      local path = data.bang and vim.api.nvim_buf_get_name(0) or vim.loop.cwd()
      minifiles.open(path)
    end, { bang = true, desc = 'Open mini.files' })

    local show_dotfiles = true
    local filter_show = function(fs_entry) return true end
    local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, '.') end

    if vim.g.mini_files_autocmd then
      vim.api.nvim_del_autocmd(vim.g.mini_files_autocmd)
      vim.g.mini_files_autocmd = nil
    end

    mines.augroup('MiniFilesEvents', {
      event = 'User',
      pattern = 'MiniFilesWindowOpen',
      command = function(args) vim.api.nvim_win_set_config(args.data.win_id, { border = 'rounded' }) end,
      desc = 'Add rounded corners to minifiles window',
    }, {
      event = 'User',
      pattern = 'MiniFilesBufferCreate',
      command = function(args)
        local buf_id = args.data.buf_id
        map_split(buf_id, '<C-s>', 'belowright horizontal')
        map_split(buf_id, '<C-v>', 'belowright vertical')
        map('n', 'g.', function()
          show_dotfiles = not show_dotfiles
          local new_filter = show_dotfiles and filter_show or filter_hide
          require('mini.files').refresh { content = { filter = new_filter } }
        end, { buffer = buf_id, nowait = true })

        local mapping = vim.tbl_filter(
        function(keymap) return keymap.callback and keymap.lhs == '<CR>' end,
        vim.api.nvim_buf_get_keymap(buf_id, 'n')
        )

        if #mapping > 0 then
          vim.keymap.set('n', '<C-LeftMouse>', mapping[1].callback, { buffer = true, nowait = true })
        end
      end,
      desc = 'Add minifiles split keymaps',
    })
  end,
}
