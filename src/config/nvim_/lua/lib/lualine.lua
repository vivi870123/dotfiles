local M = {}

local ui, highlight = mines.ui, mines.highlight
local P, icons, hls = ui.palette, ui.icons, highlight.hls

local badge = require 'lib.badge'

local function is_file_window() return vim.bo.buftype == '' end
local function is_min_width(min)
  if vim.o.laststatus > 2 then return vim.o.columns > min end
  return vim.fn.winwidth(0) > min
end

M.IndicatorBlock = {
  function() return icons.misc.block end,
  color = hls.indicator,
  padding = 0,
}
M.Modes = {
  function()
    local mode = badge.mode_names[vim.fn.mode(1)] -- :h mode()
    return badge.modes[mode].label
  end,
  cond = function() return badge.mode_names[vim.fn.mode(1)] ~= 'normal' end,
  color = function()
    local current_mode = vim.api.nvim_get_mode().mode
    local hl = badge.mode_highlight(current_mode)
    return hl
  end,
}
M.Modified = {
  function() return icons.misc.circle end,
  color = hls.modified,
  cond = function() return vim.bo.modified end,
}
M.Readonly = {
  function() return icons.misc.lock end,
  color = hls.modified,
  cond = function() return not vim.bo.modifiable or vim.bo.readonly end,
}
M.Icon = function(padding_left, padding_right)
  return {
    function() return badge.icon() end,
    padding = {
      left = padding_left or 1,
      right = padding_right or 0,
    },
  }
end
M.Filepath = {
  function()
    local fpath = badge.filepath(0, 3, 5)
    -- % char must be escaped in statusline.
    return fpath:gsub('%%', '%%%%')
  end,
  padding = { left = 1, right = 0 },
  color = hls.directory,
}
M.Branch = {
  'branch',
  cond = is_file_window,
  icon = '',
  padding = 1,
}
M.TerminalNumber = {
  function() return '#' .. vim.b['toggle_number'] end,
  cond = function() return vim.bo.buftype == 'terminal' end,
}
M.QuickfixAndLoclistTitle = {
  function()
    if vim.fn.win_gettype() == 'loclist' then return vim.fn.getloclist(0, { title = 0 }).title end
    return vim.fn.getqflist({ title = 0 }).title
  end,
  cond = function() return vim.bo.filetype == 'qf' end,
  padding = { left = 1, right = 0 },
}
M.Diagnostics = {
  'diagnostics',
  diagnostics_color = {
    -- Same values as the general color option can be used here.
    error = hls.error, -- Changes diagnostics' error color.
    warn = hls.warn, -- Changes diagnostics' warn color.
    info = hls.info, -- Changes diagnostics' info color.
    hint = hls.hint, -- Changes diagnostics' hint color.
  },
  symbols = {
    error = icons.lsp.error .. ' ',
    warn = icons.lsp.warn .. ' ',
    info = icons.lsp.info .. ' ',
    hint = icons.lsp.hint .. ' ',
  },
  padding = { left = 1, right = 0 },
}
M.GitDiff = {
  'diff',
  cond = function() return is_file_window() and is_min_width(70) end,
  source = function()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
      return {
        added = gitsigns.added,
        modified = gitsigns.changed,
        removed = gitsigns.removed,
      }
    end
  end,
  symbols = {
    added = icons.git.add .. ' ',
    modified = icons.git.mod .. ' ',
    removed = icons.git.remove .. ' ',
  },
  diff_color = {
    -- Same color values as the general color option can be used here.
    added = hls.green,
    modified = hls.warn,
    removed = hls.error,
  },
  padding = { left = 1, right = 0 },
}
M.NoiceShowCmd = {
  function() return require('noice').api.status.command.get() end,
  cond = function() return package.loaded['noice'] and require('noice').api.status.command.has() end,
  color = { fg = highlight.get('Statement', 'fg') },
}
M.NoiceShowMode = {
  function() return require('noice').api.status.mode.get() end,
  cond = function() return package.loaded['noice'] and require('noice').api.status.mode.has() end,
  color = { fg = highlight.get('Constant', 'fg') },
}
M.NoiceSearchCount = {
  function() require('noice').api.status.search.get() end,
  cond = function() return package.loaded['noice'] and require('noice').api.status.search.has() end,
  color = { fg = P.orange },
}
M.MacroRecording = {
  function() return ' Rec @' .. vim.fn.reg_recording() end,
  cond = function() return vim.fn.reg_recording() ~= '' and vim.o.cmdheight == 0 end,
  color = { fg = highlight.get('Comment', 'fg') },
}
M.LazyUpdates = {
  require('lazy.status').updates,
  cond = require('lazy.status').has_updates,
  color = { fg = highlight.get('Comment', 'fg') },
  separator = { left = '' },
}
M.FileMedia = {
  function() return badge.filemedia '  ' end,
  cond = function() return is_min_width(70) end,
  separator = { left = '' },
  padding = 1,
}
M.TelescopePrompt = {
  function()
    if is_file_window() then return '%l/%2c%4p%%' end
    return '%l/%L'
  end,
  cond = function() return vim.bo.filetype ~= 'TelescopePrompt' end,
  separator = { left = '' },
  padding = 1,
}
M.Modified_Inactive = {
  function() return vim.bo.modified and vim.bo.buftype == '' and icons.status.filename.modified or '' end,
  cond = is_file_window,
  padding = 1,
  color = { fg = P.pale_red },
}
M.FileType = {
  function() return vim.bo.filetype end,
  cond = is_file_window,
}

return M
