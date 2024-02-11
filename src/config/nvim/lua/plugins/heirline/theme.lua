local ui, highlight = mines.ui, mines.highlight
local P = ui.palette

local M = {} -- theme

local indicator_color = P.bright_blue
local error_color = mines.ui.lsp.colors.error
-- local normal_fg = highlight.get('Normal', 'fg')
local string_fg = highlight.get('String', 'fg')
local number_fg = highlight.get 'Number'
local normal_bg = highlight.get('Normal', 'bg')
local bg_color = highlight.tint(normal_bg, -0.25)

M.colors = mines.ui.palette

local hl = {
  StatusLine = { bg = bg_color },

  StatusLineNC = { highlight.get 'VertSplit' },

  Title = { fg = 'LightGray', bold = true },

  Comment = { fg = highlight.get('Comment', 'fg') },

  Number = { fg = number_fg },

  Indicator = { fg = indicator_color },

  Readonly = { fg = P.red },

  Modified = { fg = string_fg },

  WorkDir = { fg = P.grey, bold = true },

  ParentDirectory = { fg = string_fg, bold = true },

  Env = { fg = error_color, italic = true, bold = true },

  Directory = { fg = P.grey, italic = true },

  CurrentPath = { fg = string_fg, bold = true },

  HelpFileName = { fg = P.light_gray, bold = true },

  Filename = { fg = 'LightGray', bold = true },

  FileProperties = { fg = P.light_gray, bold = true },

  Git = {
    branch = { fg = P.blue, bold = true },
    added = { fg = P.green, bold = true },
    changed = { fg = P.yellow, bold = true },
    removed = { fg = P.red, bold = true },
    dirty = { fg = P.red, bold = true },
  },

  Diagnostic = {
    error = { fg = P.pale_red },
    warn = { fg = P.dark_orange },
    hint = { fg = P.bright_blue },
    info = { fg = P.teal },
  },

  MacroRecording = { fg = P.orange, bold = true },

  SearchResults = { fg = P.blue, bold = true },

  Metadata = { fg = highlight.get('Comment', 'fg') },
  Metadata_prefix = { fg = highlight.get('Comment', 'fg') },

  LspIndicator = { fg = P.blue },
  LspServer = { fg = P.dark_blue, bold = true },
}

M.highlight = hl

M.mode_colors = {
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

hl.Mode = setmetatable({ normal = { fg = M.mode_colors.normal } }, {
  __index = function(_, mode)
    return {
      bg = hl.StatusLine.bg,
      fg = M.mode_colors[mode],
      bold = true,
    }
  end,
})

return M
