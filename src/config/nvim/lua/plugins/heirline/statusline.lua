--  Types
---@class StatuslineContext
---@field bufnum     number
---@field win        number
---@field preview    boolean
---@field readonly   boolean
---@field filetype   string
---@field buftype    string
---@field modified   boolean

local api, fn, bo = vim.api, vim.fn, vim.bo
-- local devicons = require 'nvim-web-devicons'
local conditions = require 'heirline.conditions'
local theme = require 'plugins.heirline.theme'
local hl = theme.highlight
local icons = mines.ui.icons
local P = mines.ui.palette

-- Helpers
local Space = { provider = ' ' }
local Align = { provider = '%=' }
local Readonly = {
  condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
  provider = ' ' .. icons.misc.padlock,
  hl = hl.Readonly,
}

-------------
-- components
-------------
local Indicator = {
  provider = mines.ui.icons.misc.block,
  hl = hl.Indicator,
}

local Modified = {
  provider = function() return bo.modified and ' ' .. icons.misc.circle .. '' or '' end,
  hl = function(self)
    if self.ctx.modified then
      return hl.Modified
    else
      return require('plugins.heirline.theme').highlight.Mode.normal
    end
  end,
}

local ViMode = {
  init = function(self)
    local mode = setmetatable({
      n = 'normal',
      no = 'op',
      nov = 'op',
      noV = 'op',
      ['no'] = 'op',
      niI = 'normal',
      niR = 'normal',
      niV = 'normal',
      nt = 'normal',
      v = 'visual',
      V = 'visual_lines',
      [''] = 'visual_block',
      s = 'select',
      S = 'select',
      [''] = 'block',
      i = 'insert',
      ic = 'insert',
      ix = 'insert',
      R = 'replace',
      Rc = 'replace',
      Rv = 'v_replace',
      Rx = 'replace',
      c = 'command',
      cv = 'command',
      ce = 'command',
      r = 'enter',
      rm = 'more',
      ['r?'] = 'confirm',
      ['!'] = 'shell',
      t = 'terminal',
      ['null'] = 'none',
    }, {
      __call = function(this, raw_mode) return this[raw_mode] end,
    })

    local mode_label = {
      normal = 'NORMAL',
      op = 'OP',
      visual = 'VISUAL',
      visual_lines = 'VISUAL LINES',
      visual_block = 'VISUAL BLOCK',
      select = 'SELECT',
      block = 'BLOCK',
      insert = 'INSERT',
      replace = 'REPLACE',
      v_replace = 'V-REPLACE',
      command = 'COMMAND',
      enter = 'ENTER',
      more = 'MORE',
      confirm = 'CONFIRM',
      shell = 'SHELL',
      terminal = 'TERMINAL',
      none = 'NONE',
    }

    local mode_colors = {
      normal = P.grey2,
      op = P.blue,
      insert = P.blue,
      visual = P.yellow,
      visual_lines = P.yellow,
      visual_block = P.yellow,
      replace = P.red,
      v_replace = P.red,
      enter = P.aqua,
      more = P.aqua,
      select = P.purple,
      command = P.aqua,
      shell = P.orange,
      term = P.orange,
      none = P.red,
    }

    local Mode = setmetatable({
      normal = { fg = mode_colors.normal },
    }, {
      __index = function(_, m)
        return {
          bg = hl.StatusLine.bg,
          fg = mode_colors[m],

          bold = true,
        }
      end,
    })

    self.mode = mode[fn.mode(1)]
    self.mode_label = mode_label
    self.Mode = Mode
  end, -- :h mode()``
  condition = function(self) return self.ctx.buftype == '' end,
  {
    condition = function(self) return self.mode ~= 'normal' end,
    Space,
    {
      provider = function(self) return self.mode_label[self.mode] end,
      hl = function(self) return self.Mode[self.mode] end,
    },
  },
}

local FilenameBlock = {
  init = function(self)
    local sep = package.config:sub(1, 1)

    ---Only append the path separator if the path is not empty
    ---@param path string
    ---@return string
    local function path_sep(path) return not mines.falsy(path) and path .. sep or path end

    --- This function allow me to specify titles for special case buffers
    --- like the preview window or a quickfix window
    --- CREDIT: https://vi.stackexchange.com/a/18090
    --- @param ctx StatuslineContext
    local function special_buffers(ctx)
      local location_list = fn.getloclist(0, { filewinid = 0 })
      local is_loc_list = location_list.filewinid > 0
      local normal_term = ctx.buftype == 'terminal' and ctx.filetype == ''

      if is_loc_list then return 'Location List' end
      if ctx.buftype == 'quickfix' then return 'Quickfix List' end
      if normal_term then return 'Terminal(' .. fn.fnamemodify(vim.env.SHELL, ':t') .. ')' end
      if ctx.preview then return 'preview' end

      if ctx.filetype == 'TelescopePrompt' then return 'Telescope' end
      if ctx.filetype == 'minifiles' then return 'Files' end
      if ctx.filetype == 'mason' then return 'Mason' end
      if ctx.filetype == 'null-ls-info' then return 'NullLS Info' end
      if ctx.filetype == 'lspinfo' then return 'Lsp Info' end
      if ctx.filetype == 'noice' then return 'Notifications' end
      if ctx.filetype == 'dbui' then return 'Dadbod UI' end
      if ctx.filetype == 'help' then return 'Help' end
      if ctx.filetype == 'gitcommit' then return 'Git commit' end
      if ctx.filetype == 'tsplayground' then return 'Treesitter' end
      if ctx.filetype == 'NeogitStatus' then return 'Neogit Status' end
      if ctx.filetype == 'undotree' then return 'Undotree' end
      if ctx.filetype == 'DiffviewFiles' then return 'Diff View' end
      if ctx.filetype == 'dap-repl' then return 'Debugger REPL' end
      if ctx.filetype == 'troube' then return 'Lsp Trouble' end
      if ctx.filetype == 'lazy' then return 'Plugin Manager' end
      if ctx.filetype == 'ccc-ui' then return 'Color Picker' end

      if ctx.filetype == 'toggleterm' then
        local shell = vim.fn.fnamemodify(vim.env.SHELL, ':t')
        return string.format('Terminal(%s)[%s]', shell, vim.api.nvim_buf_get_var(ctx.bufnum, 'toggle_number'))
      end

      if ctx.filetype == 'neo-tree' then
        local path = api.nvim_buf_get_name(ctx.bufnum)
        local parts = vim.split(path, ' ')
        return string.format('Neo Tree(%s)', parts[2])
      end

      return nil
    end

    --- Replace the directory path with an identifier if it matches a commonly visited
    --- directory of mine such as my projects directory or my work directory
    --- since almost all my project directories are nested underneath one of these paths
    --- this should match often and reduce the unnecessary boilerplate in my path as
    --- I know where these directories are generally
    ---@param directory string
    ---@return string directory
    ---@return string custom_dir
    local function dir_env(directory)
      if not directory then return '', '' end
      local paths = {
        -- [vim.g.dotfiles] = '$DOTFILES',
        -- [vim.g.projects_dir] = '$PROJECTS',
      }
      local result, env, prev_match = directory, '', ''
      for dir, alias in pairs(paths) do
        local match, count = fn.expand(directory):gsub(vim.pesc(path_sep(dir)), '')
        if count == 1 and #dir > #prev_match then
          result, env, prev_match = match, path_sep(alias), dir
        end
      end
      return result, env
    end

    --- @param ctx StatuslineContext
    --- @return {env: string, dir: string, parent: string, fname: string}
    local function filename(ctx)
      local buf = ctx.bufnum
      local special_buf = special_buffers(ctx)
      if special_buf then return { fname = special_buf } end

      local path = api.nvim_buf_get_name(buf)
      if mines.falsy(path) then return { fname = 'No Name' } end
      --- add ":." to the expansion i.e. to make the directory path relative to the current vim directory
      local parts = vim.split(fn.fnamemodify(path, ':~'), sep)
      local fname = table.remove(parts)

      local parent = table.remove(parts)
      fname = fn.isdirectory(fname) == 1 and fname .. sep or fname
      if mines.falsy(parent) then return { fname = fname } end

      local dir = path_sep(table.concat(parts, sep))
      if api.nvim_strwidth(dir) > math.floor(vim.o.columns / 3) then dir = fn.pathshorten(dir) end

      local new_dir, env = dir_env(dir)
      return { env = env, dir = new_dir, parent = path_sep(parent), fname = fname }
    end

    ---@alias FilenamePart {item: string, hl: string, opts: ComponentOpts}
    ---Create the various segments of the current filename
    ---@param ctx StatuslineContext
    ---@param minimal boolean
    ---@return {file: FilenamePart, parent: FilenamePart, dir: FilenamePart, env: FilenamePart}
    local function stl_file(ctx, minimal)
      local p = filename(ctx)

      return {
        env = { item = p.env, hl = hl.Env },
        file = { item = p.fname, hl = hl.Filename },
        dir = { item = p.dir, hl = hl.Directory },
        parent = { item = p.parent, hl = hl.ParentDirectory },
      }
    end

    local segments = stl_file(self.ctx, false)

    self.env = segments.env
    self.dir = segments.dir
    self.parent = segments.parent
    self.file = segments.file
  end,
  {
    {
      provider = function(self) return self.env.item end,
      hl = function(self) return self.env.hl end,
    }, -- EnvComponent
    {
      provider = function(self) return self.dir.item end,
      hl = function(self) return self.dir.hl end,
    }, -- DirComponent
    {
      provider = function(self) return self.parent.item end,
      hl = function(self) return self.parent.hl end,
    }, -- ParentComponent
    {
      provider = function(self) return self.file.item end,
      hl = function(self) return self.file.hl end,
    }, -- FileComponent
  },
  { provider = '%<' },
}

local Macro = {
  condition = function() return fn.reg_recording() ~= '' and vim.o.cmdheight == 0 end,
  {
    provider = function() return ' Recording @' .. fn.reg_recording() end,
    hl = hl.Title,
  },
  Space,
}

local SearchResult = {
  condition = function(self)
    local lines = api.nvim_buf_line_count(0)
    if lines > 50000 then return end

    local query = fn.getreg '/'
    if query == '' then return end
    if query:find '@' then return end

    local search_count = fn.searchcount { recompute = 1, maxcount = -1 }
    local active = false
    if vim.v.hlsearch and vim.v.hlsearch == 1 and search_count.total > 0 then active = true end
    if not active then return end

    query = query:gsub([[^\V]], '')
    query = query:gsub([[\<]], ''):gsub([[\>]], '')

    self.query = query
    self.count = search_count
    return true
  end,
  {
    provider = function(self) return table.concat { ' ', self.count.current, '/', self.count.total, ' ' } end,
    hl = hl.SearchResults,
  },
  Space,
}

--- @type {head: string?, added: integer?, changed: integer?, removed: integer?}
local Git = {
  init = function(self)
    self.git_status = vim.b.gitsigns_status_dict
    self.head = self.git_status.head
  end,
  condition = function(self)
    if conditions.is_git_repo() then
      self.git_status = vim.b.gitsigns_status_dict
      local has_changes = self.git_status.added ~= 0 or self.git_status.removed ~= 0 or self.git_status.changed ~= 0
      return has_changes
    end
  end,
  {
    provider = function() return ' ' end,
    hl = hl.Metadata,
  },
  {
    provider = function(self) return self.git_status.head end,
    hl = hl.Git.branch,
  },
  {
    provider = '  ',
    hl = hl.Git.dirty,
  },
  { provider = ' ' },
}

local Updates = {
  condition = function() return require('lazy.status').updates() or false end,
  { provider = 'updates:', hl = hl.Comment },
  Space,
  { provider = require('lazy.status').updates or nil, hl = hl.Title },
  { provider = '  ' },
}

local Lsp = {
  condition = require('heirline.conditions').lsp_attached,
  update = { 'LspAttach', 'LspDetach', 'BufWinEnter' },
  init = function(self)
    local names = {}
    for _, server in pairs(vim.lsp.buf_get_clients(0)) do
      table.insert(names, server.name)
    end
    self.lsp_names = names
  end,
  {
    provider = ' LSP(s): ',
    hl = hl.Comment,
  },
  {
    provider = function(self)
      local names = self.lsp_names
      if #names == 1 then
        names = names[1]
      else
        names = table.concat(names, ', ')
      end
      return names
    end,
    hl = hl.Title,
  },
  {
    provider = '  ',
  },
}

local Diagnostics = {
  condition = conditions.has_diagnostics,
  static = {
    error_icon = icons.lsp.error .. ' ',
    warn_icon = icons.lsp.warn .. ' ',
    info_icon = icons.lsp.info .. ' ',
    hint_icon = icons.lsp.hint .. ' ',
  },
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,
  {
    provider = function(self)
      -- 0 is just another output, we can decide to print it or not!
      if self.errors > 0 then return table.concat { self.error_icon, self.errors, ' ' } end
    end,
    hl = hl.Diagnostic.error,
  },
  {
    provider = function(self)
      if self.warnings > 0 then return table.concat { self.warn_icon, self.warnings, ' ' } end
    end,
    hl = hl.Diagnostic.warn,
  },
  {
    provider = function(self)
      if self.info > 0 then return table.concat { self.info_icon, self.info, ' ' } end
    end,
    hl = hl.Diagnostic.info,
  },
  {
    provider = function(self)
      if self.hints > 0 then return table.concat { self.hint_icon, self.hints, ' ' } end
    end,
    hl = hl.Diagnostic.hint,
  },
  Space,
}

local LineProperties = {
  init = function(self)
    self.lnum, self.col = unpack(api.nvim_win_get_cursor(self.ctx.win))
    self.col = self.col + 1 -- this should be 1-indexed, but isn't by default
    self.line_count = api.nvim_buf_line_count(self.ctx.bufnum)
  end,
  { provider = icons.misc.line, hl = hl.Metadata_prefix }, -- icon
  Space,
  {
    provider = function(self)
      local lnum, _ = unpack(api.nvim_win_get_cursor(self.ctx.win))
      return string.format('%+' .. vim.api.nvim_strwidth(tostring(self.line_count)) .. 's', lnum)
    end,
    hl = hl.Title,
  },
  { provider = '/', hl = hl.Comment },
  {
    provider = function(self) return self.line_count end,
    hl = hl.Comment,
  },
  Space,
  {
    provider = 'Col:',
    hl = hl.Metadata_prefix,
  },
  Space,
  {
    provider = function(self) return string.format('%+2s', self.col) end,
    hl = hl.Title,
  },
}

local statusline = {
  init = function(self)
    local curwin = api.nvim_get_current_win()
    local curbuf = api.nvim_win_get_buf(curwin)

    ---@type StatuslineContext
    self.ctx = {
      bufnum = curbuf,
      win = curwin,
      preview = vim.wo[curwin].previewwindow,
      readonly = vim.bo[curbuf].readonly,
      filetype = vim.bo[curbuf].ft,
      buftype = vim.bo[curbuf].bt,
      modified = vim.bo[curbuf].modified,
    }
  end,
  Indicator,
  Modified,
  Readonly,
  ViMode,
  Space,
  SearchResult,
  FilenameBlock,
  Space,
  Diagnostics,
  Align,
  Macro,
  Align,
  Updates,
  Lsp,
  Git,

  LineProperties,
  Space,
  hl = 'Statusline',
}

mines.augroup('Heirline', {
  event = 'ColorScheme',
  command = function()
    if not vim.g.is_saving and vim.bo.modified then
      vim.g.is_saving = true
      vim.defer_fn(function() vim.g.is_saving = false end, 1000)
    end
  end,
})

return statusline
