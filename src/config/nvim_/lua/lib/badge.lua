local icons, lsp, highlight, decorations = mines.ui.icons, mines.ui.lsp, mines.highlight, mines.ui.decorations
local api, fn, fs, fmt, strwidth = vim.api, vim.fn, vim.fs, string.format, vim.api.nvim_strwidth
local P, falsy = mines.ui.palette, mines.falsy

local plugin_icons = {
  DiffviewFiles = { '' },
  fugitive = { ' ' },
  fugitiveblame = { '󰊢', 'Blame' },
  lazy = { '󰒲 ', 'Lazy.nvim' },
  loclist = { '󰂖', 'Location List' },
  mason = { '󰈏 ', 'Mason' },
  NeogitStatus = { '', 'Neogit Status' },
  ['neo-tree'] = { ' ', 'Neo-tree' },
  ['neo-tree-popup'] = { '󰋱', 'Neo-tree' },
  Outline = { ' ' },
  quickfix = { ' ', 'Quickfix List' }, -- 󰎟 
  spectre_panel = { '󰥩 ', 'Spectre' },
  TelescopePrompt = { '󰋱', 'Telescope' },
  terminal = { ' ' },
  toggleterm = { ' ', 'Terminal' },
  Trouble = { '', 'Lsp Trouble' }, --  
  undotree = { '󰃢', 'UndoTree' },
  ['neotest.*'] = { 'פּ', 'Testing' },
  ['himalaya-msg-list'] = { '', 'Inbox' },
  ['dapui_.*'] = { '' },
  ['dap-repl'] = { '', 'Debugger REPL' },
  fzf = { '', 'FZF' },
  log = { '' },
  org = { '', 'Org' },
  orgagenda = { '' },
  mail = { '', 'Mail' },
  dbui = { '', 'Dadbod UI' },
  tsplayground = { '侮', 'Treesitter' },
  norg = { 'ﴬ' },
  help = { '', 'Help' },
  octo = { '', 'Octo' },
  minimap = { '', '' },
  NvimTree = { 'פּ', 'Nvim Tree' },

  -- ['neotest.*'] = 'Testing',
  --
  -- ['log'] = function(fname, _) return string.format('Log(%s)', vim.fs.basename(fname)) end,
  --
  -- ['dapui_.*'] = function(fname) return fname end,
  --
  -- ['neo-tree'] = function(fname, _)
  --   local parts = vim.split(fname, ' ')
  --   return string.format('Neo Tree(%s)', parts[2])
  -- end,
  --
  -- ['toggleterm'] = function(_, buf)
  --   local shell = fn.fnamemodify(vim.env.SHELL, ':t')
  --   return string.format('Terminal(%s)[%s]', shell, api.nvim_buf_get_var(buf, 'toggle_number'))
  -- end,
}

local cache_keys = {
  'badge_cache_filepath',
  'badge_cache_filepath_tab',
  'badge_cache_icon',
}

mines.augroup('badge_icons', {
  event = { 'BufReadPost', 'BufFilePost', 'BufNewFile', 'BufWritePost' },
  command = function()
    if vim.bo.buftype ~= '' then return end
    for _, cache_key in ipairs(cache_keys) do
      pcall(vim.api.nvim_buf_del_var, 0, cache_key)
    end
  end,
}, {
  event = { 'BufWritePre', 'FileChangedShellPost', 'TextChanged', 'InsertLeave' },
  command = function() pcall(vim.api.nvim_buf_del_var, 0, 'badge_cache_trails') end,
})

local M = {}

local hls = highlight.hls

-- Mode related
M.mode_names = setmetatable({
  n = 'normal',
  no = 'op',
  nov = 'op',
  noV = 'op',
  niI = 'normal',
  niR = 'normal',
  niV = 'normal',
  nt = 'normal',
  v = 'visual',
  V = 'visual_lines',
  ['\22'] = 'visual_block',
  ['\22s'] = 'visual_block',
  s = 'select',
  S = 'select',
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
  __call = function(self, raw_mode) return self[raw_mode] end,
})

M.modes = {
  normal = { color = P.light_gray, label = 'NORMAL' },
  op = { color = P.dark_blue, label = 'OP' },
  insert = { color = P.blue, label = 'INSERT' },
  visual = { color = P.magenta, label = 'VISUAL' },
  visual_lines = { color = P.magenta, label = 'VISUAL LINES' },
  visual_block = { color = P.magenta, label = 'VISUAL BLOCK' },
  replace = { color = P.dark_red, label = 'REPLACE' },
  v_replace = { color = P.dark_red, label = 'V-REPLACE' },
  enter = { color = P.aqua, label = 'ENTER' },
  more = { color = P.aqua, label = 'MORE' },
  select = { color = P.teal, label = 'SELECT' },
  command = { color = P.light_yellow, label = 'COMMAND' },
  shell = { color = P.orange, label = 'SHELL' },
  term = { color = P.orange, label = 'TERMINAL' },
  none = { color = P.dark_red, label = 'NONE' },
  block = { color = P.dark_red, label = 'BLOCK' },
  confirm = { color = P.dark_red, label = 'CONFIRM' },
}

function M.mode_highlight(mode)
  local visual_regex = vim.regex [[\(s\|S\|\)]]
  local select_regex = vim.regex [[\(v\|V\|\)]]
  local command_regex = vim.regex [[\(c\|cv\|ce\)]]
  local replace_regex = vim.regex [[\(Rc\|R\|Rv\|Rx\)]]
  if mode == 'i' then
    return hls.mode_insert
  elseif visual_regex and visual_regex:match_str(mode) then
    return hls.mode_visual
  elseif select_regex and select_regex:match_str(mode) then
    return hls.mode_select
  elseif replace_regex and replace_regex:match_str(mode) then
    return hls.mode_replace
  elseif command_regex and command_regex:match_str(mode) then
    return hls.mode_command
  else
    return hls.mode_normal
  end
end

-- Provides relative path with limited characters in each directory name, and
-- limits number of total directories. Caches the result for current buffer.
---@param bufnr integer buffer number
---@param max_dirs integer max dirs to show
---@param dir_max_chars integer max chars in dir
---@param cache_suffix string? cache suffix
---@return string
function M.filepath(bufnr, max_dirs, dir_max_chars, cache_suffix)
  local msg = ''
  local cache_key = 'badge_cache_filepath' -- _'..ft
  if cache_suffix then cache_key = cache_key .. cache_suffix end
  local cache_ok, cache = pcall(vim.api.nvim_buf_get_var, bufnr, cache_key)
  if cache_ok then return cache end

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local buftype = vim.bo[bufnr].buftype
  local filetype = vim.bo[bufnr].filetype

  -- Normalize bufname
  if bufname:len() < 1 and buftype:len() < 1 then return 'N/A' end
  bufname = vim.fn.fnamemodify(bufname, ':~:.') or ''

  -- Reduce directory count according to 'max_dirs' setting.
  local formatter = string.format('([^%s]+)', '/')
  local parts = {}
  for str in string.gmatch(bufname, formatter) do
    table.insert(parts, str)
  end

  local short_parts = {}
  for i = #parts, 1, -1 do
    if #short_parts <= max_dirs then table.insert(short_parts, 1, parts[i]) end
  end
  bufname = table.concat(short_parts, '/')

  -- Reduce each directory character count according to setting.
  bufname = vim.fn.pathshorten(bufname, dir_max_chars + 1)

  -- Override with plugin names.
  local plugin_type = filetype == 'qf' and vim.fn.win_gettype() or filetype
  if plugin_icons[plugin_type] ~= nil and #plugin_icons[plugin_type] > 1 then
    msg = msg .. plugin_icons[plugin_type][2]
  else
    msg = msg .. bufname
  end

  vim.api.nvim_buf_set_var(bufnr, cache_key, msg)
  return msg
end

function M.filemedia(separator)
  local parts = {}
  if vim.bo.fileformat ~= '' and vim.bo.fileformat ~= 'unix' then table.insert(parts, vim.bo.fileformat) end
  if vim.bo.fileencoding ~= '' and vim.bo.fileencoding ~= 'utf-8' then table.insert(parts, vim.bo.fileencoding) end
  if vim.bo.filetype ~= '' then table.insert(parts, vim.bo.filetype) end
  return table.concat(parts, separator)
end

function M.icon(bufnr)
  bufnr = bufnr or 0
  local cache_key = 'badge_cache_icon'
  local cache_ok, cache = pcall(vim.api.nvim_buf_get_var, bufnr, cache_key)
  if cache_ok then return cache end

  local icon = ''
  local ft = vim.bo[bufnr].filetype
  local buftype = vim.bo[bufnr].buftype
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  local plugin_type = ft == 'qf' and vim.fn.win_gettype() or ft
  if buftype ~= '' and plugin_icons[plugin_type] ~= nil then
    icon = plugin_icons[plugin_type][1]
  else
    -- Try nvim-tree/nvim-web-devicons
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    if ok then
      if buftype == '' and bufname == '' then return devicons.get_default_icon().icon end
      local f_name = vim.fn.fnamemodify(bufname, ':t')
      local f_extension = vim.fn.fnamemodify(bufname, ':e')
      icon, _ = devicons.get_icon(f_name, f_extension)
      if icon == '' or icon == nil then icon = devicons.get_default_icon().icon end
    end
  end
  vim.api.nvim_buf_set_var(bufnr, cache_key, icon)
  return icon
end

-- Detect trailing whitespace and cache result per buffer
---@param symbol string
---@return string
function M.trails(symbol)
  local cache_key = 'badge_cache_trails'
  local cache_ok, cache = pcall(vim.api.nvim_buf_get_var, 0, cache_key)
  if cache_ok then return cache end

  local msg = ''
  if not vim.bo.readonly and vim.bo.modifiable and vim.fn.line '$' < 9000 then
    local trailing = vim.fn.search('\\s$', 'nw')
    if trailing > 0 then
      local label = symbol or 'WS:'
      msg = msg .. label .. trailing
    end
  end
  vim.api.nvim_buf_set_var(0, cache_key, msg)

  return msg
end

return M
