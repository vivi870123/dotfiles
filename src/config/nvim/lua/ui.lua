----------------------------------------------------------------------------------------------------
-- Styles
----------------------------------------------------------------------------------------------------

mines.ui.palette = {
  dark_green = '#10B981',
  sky_blue = '#89dceb',
  bright_blue = '#51afef',
  pale_pink = '#b490c0',
  mauve = '#c292a1',
  red = '#ff6c6b',
  pale_red = '#E06C75',
  light_red = '#c43e1f',
  dark_red = '#be5046',
  rosewater = '#ff9898',
  flamingo = '#fc8eac',
  dark_orange = '#FF922B',
  bright_yellow = '#FAB005',
  light_yellow = '#e5c07b',
  whitesmoke = '#9E9E9E',
  light_gray = '#626262',
  comment_grey = '#5c6370',
  grey = '#3E4556',
  sapphire = '#051f42',
  orange = '#da8548',
  green = '#98be65',
  teal = '#4db5bd',
  yellow = '#ECBE7B',
  blue = '#51afef',
  dark_blue = '#2257A0',
  magenta = '#c678dd',
  violet = '#a9a1e1',
  cyan = '#46D9FF',
  dark_cyan = '#5699AF',
  white = '#efefef',
}

mines.ui.border = {
  line = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' },
  rectangle = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
}

mines.ui.icons = {
  separators = {
    left_thin_block = '▏',
    right_thin_block = '▕',
    left_holow_pipe = '▎',
    left_block = '▌',
    hollow_pipe = '│',
    slant_left_thin = '',
    slant_right_thin = '',
    slant_right_top = '',
    slant_right_bottom = '',
    slant_left_top = '',
    slant_left_bottom = '',
    circle_left = '',
    circle_right = '',
    arrow_right = '',
    arrow_left = '',
    right_block = '🮉',
    light_shade_block = '░',
    medium_shade_block = '▒',
    vert_bottom_half_block = '▄',
    vert_top_half_block = '▀',
  },
  lsp = {
    error = '', -- '✗'
    warn = '', -- 
    info = '󰋼', --  ℹ 󰙎 
    hint = '󰌶', --  ⚑
  },
  git = {
    add = '', -- '',
    mod = '',
    remove = '', -- '',
    ignore = '',
    rename = '',
    untracked = '',
    ignored = '',
    unstaged = '󰄱',
    staged = '',
    conflict = '',
    diff = '',
    repo = '',
    logo = '󰊢',
    branch = '',
  },
  documents = {
    file = '',
    files = '',
    folder = '',
    folder_alt = ' ',
    open_folder = '',
  },
  misc = {
    beaker = ' ',
    canceled = '󰜺 ',
    ellipsis = '…',
    failure = ' ',
    hack = ' ',
    note = ' ',
    running = '󰑮 ',
    success = '󰄴 ',
    perf = ' ',
    todo = '',
    test = '⏲ ',
    startup = ' ',
    plus = '',
    up = '⇡',
    down = '⇣',
    line = '', -- 'ℓ'
    indent = 'Ξ',
    tab = '⇥',
    bug = '', --  '󰠭'
    question = '',
    clock = '',
    lock = '',
    padlock = '',
    shaded_lock = '',
    circle_small = '●', -- ●
    circle = '',
    circle_plus = '⊕ ',
    circle_o = '⭘', -- ⭘
    fold_close = '',
    fold_open = '',
    fold_separator = ' ',
    project = '',
    dashboard = '',
    history = '󰄉',
    comment = '󰅺',
    robot = '󰚩',
    lightbulb = '󰌵',
    search = '󰍉',
    code = '',
    telescope = '',
    gear = '',
    package = '',
    list = '',
    sign_in = '',
    check = '󰄬',
    fire = '',
    bookmark = '',
    pencil = '', -- '󰏫',
    tools = '',
    arrow_right = '',
    caret_right = '',
    chevron_right = '',
    double_chevron_right = '»',
    table = '',
    calendar = '',
    block = '▌',
    vim = ' ',
  },
}
mines.ui.lsp = {
  colors = {
    error = mines.ui.palette.pale_red,
    warn = mines.ui.palette.dark_orange,
    hint = mines.ui.palette.bright_blue,
    info = mines.ui.palette.teal,
  },
  --- This is a mapping of LSP Kinds to highlight groups. LSP Kinds come via the LSP spec
  --- see: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
  highlights = {
    File = 'Directory',
    Snippet = 'Label',
    Text = '@string',
    Method = '@method',
    Function = '@function',
    Constructor = '@constructor',
    Field = '@field',
    Variable = '@variable',
    Module = '@namespace',
    Property = '@property',
    Unit = '@constant',
    Value = '@variable',
    Enum = '@type',
    Keyword = '@keyword',
    Reference = '@parameter.reference',
    Constant = '@constant',
    Struct = '@structure',
    Event = '@variable',
    Operator = '@operator',
    Namespace = '@namespace',
    Package = '@include',
    String = '@string',
    Number = '@number',
    Boolean = '@boolean',
    Array = '@repeat',
    Object = '@type',
    Key = '@field',
    Null = '@symbol',
    EnumMember = '@field',
    Class = '@lsp.type.class',
    Interface = '@lsp.type.interface',
    TypeParameter = '@lsp.type.parameter',
  },
}

----------------------------------------------------------------------------------------------------
-- UI Settings
----------------------------------------------------------------------------------------------------
---@class Decorations {
---@field winbar 'ignore' | boolean
---@field number boolean
---@field statusline 'minimal' | boolean
---@field statuscolumn boolean
---@field colorcolumn boolean | string

---@alias DecorationType 'statuscolumn'|'winbar'|'statusline'|'number'|'colorcolumn'

---@class Decorations
local Preset = {}

---@param o Decorations
function Preset:new(o)
  assert(o, 'a preset must be defined')
  self.__index = self
  return setmetatable(o, self)
end

--- WARNING: deep extend does not copy lua meta methods
function Preset:with(o) return vim.tbl_deep_extend('force', self, o) end

---@type table<string, Decorations>
local presets = {
  statusline_only = Preset:new {
    number = false,
    winbar = false,
    colorcolumn = false,
    statusline = true,
    statuscolumn = false,
  },
  minimal_editing = Preset:new {
    number = false,
    winbar = true,
    colorcolumn = false,
    statusline = 'minimal',
    statuscolumn = false,
  },
  tool_panel = Preset:new {
    number = false,
    winbar = false,
    colorcolumn = false,
    statusline = 'minimal',
    statuscolumn = false,
  },
}

local commit_buffer = presets.minimal_editing:with { colorcolumn = '50,72', winbar = false }

local buftypes = {
  ['quickfix'] = presets.tool_panel,
  ['nofile'] = presets.tool_panel,
  ['nowrite'] = presets.tool_panel,
  ['acwrite'] = presets.tool_panel,
  ['terminal'] = presets.tool_panel,
}

--- When searching through the filetypes table if a match can't be found then search
--- again but check if there is matching lua pattern. This is useful for filetypes for
--- plugins like Neogit which have a filetype of Neogit<something>.
local filetypes = mines.p_table {
  ['startuptime'] = presets.tool_panel,
  ['checkhealth'] = presets.tool_panel,
  ['log'] = presets.tool_panel,
  ['help'] = presets.tool_panel,
  ['dbout'] = presets.tool_panel,
  ['dbui'] = presets.tool_panel,
  ['dapui'] = presets.tool_panel,
  ['minimap'] = presets.tool_panel,
  ['Trouble'] = presets.tool_panel,
  ['tsplayground'] = presets.tool_panel,
  ['list'] = presets.tool_panel,
  ['netrw'] = presets.tool_panel,
  ['NvimTree'] = presets.tool_panel,
  ['undotree'] = presets.tool_panel,
  ['dap-repl'] = presets.tool_panel:with { winbar = 'ignore' },
  ['toggleterm'] = presets.tool_panel:with { winbar = 'ignore' },
  ['neotest.*'] = presets.tool_panel,
  ['^Neogit.*'] = presets.tool_panel,
  ['query'] = presets.tool_panel,
  ['DiffviewFiles'] = presets.tool_panel,
  ['DiffviewFileHistory'] = presets.tool_panel,
  ['mail'] = presets.statusline_only,
  ['noice'] = presets.statusline_only,
  ['diff'] = presets.statusline_only,
  ['qf'] = presets.statusline_only,
  ['starter'] = presets.statusline_only,
  ['man'] = presets.minimal_editing,
  ['org'] = presets.minimal_editing:with { winbar = false },
  ['norg'] = presets.minimal_editing:with { winbar = false },
  ['orgagenda'] = presets.minimal_editing:with { winbar = false },
  ['markdown'] = presets.minimal_editing,
  ['gitcommit'] = commit_buffer,
  ['NeogitCommitMessage'] = commit_buffer,
}

local filenames = mines.p_table {
  ['option-window'] = presets.tool_panel,
}

mines.ui.decorations = {}

---@alias ui.OptionValue (boolean | string)

---Get the mines.ui setting for a particular filetype
---@param opts {ft: string?, bt: string?, fname: string?, setting: DecorationType}
---@return {ft: ui.OptionValue?, bt: ui.OptionValue?, fname: ui.OptionValue?}
function mines.ui.decorations.get(opts)
  local ft, bt, fname, setting = opts.ft, opts.bt, opts.fname, opts.setting
  if (not ft and not bt and not fname) or not setting then return nil end
  return {
    ft = ft and filetypes[ft] and filetypes[ft][setting],
    bt = bt and buftypes[bt] and buftypes[bt][setting],
    fname = fname and filenames[fname] and filenames[fname][setting],
  }
end

---A helper to set the value of the colorcolumn option, to my preferences, this can be used
---in an autocommand to set the `vim.opt_local.colorcolumn` or by a plugin such as `virtcolumn.nvim`
---to set it's virtual column
---@param bufnr integer
---@param fn fun(virtcolumn: string)
function mines.ui.decorations.set_colorcolumn(bufnr, fn)
  local buf = vim.bo[bufnr]
  local decor = mines.ui.decorations.get { ft = buf.ft, bt = buf.bt, setting = 'colorcolumn' }
  if buf.ft == '' or buf.bt ~= '' or decor.ft == false or decor.bt == false then return end
  local ccol = decor.ft or decor.bt or ''
  local virtcolumn = not mines.falsy(ccol) and ccol or '+1'
  if vim.is_callable(fn) then fn(virtcolumn) end
end

----------------------------------------------------------------------------------------------------
mines.ui.current = { border = mines.ui.border.line }
