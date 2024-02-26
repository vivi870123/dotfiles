local o, opt, opt_global, fn = vim.o, vim.opt, vim.opt_global, vim.fn

-----------------------------------------------------------------------------//
-- General
-----------------------------------------------------------------------------//
vim.o.laststatus = 3 -- Always show statusline

-- Leader bindings
vim.g.mapleader = ' ' -- Leader key
vim.g.maplocalleader = ';' -- Local leader

-- Title
-- function mines.modified_icon() return vim.bo.modified and mines.ui.icons.misc.plus or '' end
-- o.titlestring = ' %{fnamemodify(getcwd(), ":t")}%( %{v:lua.mines.modified_icon()}%)'
o.titleold = fn.fnamemodify(vim.loop.os_getenv 'SHELL', ':t')
o.title = true
o.titlelen = 70

-- Timings
opt.updatetime = 300
opt.timeoutlen = 500
opt.timeout = true
opt.ttimeoutlen = 10

-- Spelling
opt.spelllang = { 'en' }
opt.spellsuggest:prepend { 12 }
opt.spelloptions:append { 'camel', 'noplainbuffer' }
opt.spellcapcheck = '' -- don't check for capital letters at start of sentence

-- Mouse
opt.mouse = 'i'
opt.mousefocus = true
opt.mousemoveevent = true
opt.mousescroll = { 'ver:1', 'hor:6' }

opt.virtualedit = 'block' -- allow cursor to move where there is no text in visual block mode
opt.autowriteall = true -- Allow auto-write when focus is lost
opt.clipboard = 'unnamedplus' -- Sync with system clipboard
opt.conceallevel = 3

-- opt.completeopt = 'menuone,noselect'
opt.completeopt = 'menu,menuone,noselect'
opt.wildcharm = ('\t'):byte()
opt.wildmode = 'list:full' -- Shows a menu bar as opposed to an enormous list
opt.wildignorecase = true -- Ignore case when completing file names and directories
opt.wildignore = {
  '*.o',
  '*.obj',
  '*.dll',
  '*.jar',
  '*.pyc',
  '*.rbc',
  '*.class',
  '*.gif',
  '*.ico',
  '*.jpg',
  '*.jpeg',
  '*.png',
  '*.avi',
  '*.wav',
  '*.swp',
  '.lock',
  '.DS_Store',
  'tags.lock',
}
opt.wildoptions = { 'pum', 'fuzzy' }

-- Diff
-- use in vertical diff mode, blank lines to keep sides aligned, Ignore whitespace changes
opt.diffopt:append {
  'vertical',
  'iwhite',
  'hiddenoff',
  'foldcolumn:0',
  'context:4',
  'algorithm:histogram',
  'indent-heuristic',
  'linematch:60',
}

-- Indentation
opt.textwidth = 80
opt.autoindent = true
opt.shiftround = true
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true -- Smart autoindenting on new lines

-- Sessions
-- What to save for views and sessions
opt.viewoptions:remove 'folds'
opt.sessionoptions:remove { 'blank', 'terminal' }
opt.sessionoptions:append { 'globals', 'skiprtp' }

-- Match and search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = 'nosplit' -- Preview incremental substitute
opt.wrapscan = true -- Searches wrap around the end of the file

-- Backup & swaps
opt.undofile = true
opt.undolevels = 10000
opt.backup = false
opt.swapfile = false
opt.writebackup = false

-- grepprg
-- use faster grep alternatives if possible
if fn.executable 'rg' == 1 then
  o.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
elseif fn.executable 'ag' == 1 then
  o.grepprg = [[ag --nogroup --nocolor --vimgrep]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
end

-- If sudo, disable vim swap/backup/undo/shada writing
local USER = vim.env.USER or ''
local SUDO_USER = vim.env.SUDO_USER or ''
if
  SUDO_USER ~= ''
  and USER ~= SUDO_USER
  and vim.env.HOME ~= fn.expand('~' .. USER, true)
  and vim.env.HOME == fn.expand('~' .. SUDO_USER, true)
then
  opt_global.modeline = false
  opt_global.undofile = false
  opt_global.swapfile = false
  opt_global.backup = false
  opt_global.writebackup = false
  opt_global.shadafile = 'NONE'
end

-----------------------------------------------------------------------------//
-- Formatting
-----------------------------------------------------------------------------//

opt.wrap = false -- No wrap by default
opt.wrapmargin = 2
opt.linebreak = true -- Break long lines at 'breakat'
opt.breakindent = true

opt.formatoptions = opt.formatoptions
  - 'a' -- Auto formatting is BAD.
  - 't' -- Don't auto format my code
  + 'c' -- Auto-wrap comments using textwidth
  + 'q' -- Allow formatting comments w/ gq
  - 'o' -- O and o, don't continue comments
  + 'r' -- But do continue when pressing enter.
  + 'n' -- Indent past the formatlistpat, not underneath it.
  + 'j' -- remove a comment leader when joining lines.
  - '1'
  - '2' -- Use indent from 2nd line of a paragraph
  + 'l' -- Only break if the line was not longer than 'textwidth' when the insert
  + 'v'
  - 't' -- autowrap lines using text width value

-----------------------------------------------------------------------------//
-- Editor UI
-----------------------------------------------------------------------------//
opt.termguicolors = true -- True color support

opt.shortmess = {
  a = true,
  t = true, -- truncate file messages at start
  A = true, -- ignore annoying swap file messages
  o = true, -- file-read message overwrites previous
  O = true, -- file-read message overwrites previous
  T = true, -- truncate non-file messages in middle
  f = true, -- (file x of x) instead of just (x of x
  F = true, -- Don't give file info when editing a file, NOTE: this breaks autocommand messages
  s = true,
  I = true,
  c = true,
  W = true, -- Don't show [w] or written when writing
}

opt.showcmd = false -- Don't show command in status line
opt.showmode = false -- Don't show mode in cmd window
opt.sidescroll = 1
opt.scrolloff = 4 -- Keep at least 2 lines above/below
opt.sidescrolloff = 8 -- Keep at least 5 lines left/right
opt.numberwidth = 2 -- Minimum number of columns to use for the line number
opt.number = false -- Don't show line numbers
opt.ruler = false -- Disable default status ruler
opt.list = true -- Show hidden characters
opt.splitbelow = true -- New split at bottom
opt.splitright = true -- New split on right
opt.splitkeep = 'screen' -- New split keep the text on the same screen line

opt.cmdheight = 1 -- NOTE: temporary
-- opt.colorcolumn = '+0'    -- Align text at 'textwidth'
opt.showtabline = 1 -- show the tabline if there is 2 tabs
opt.helpheight = 0 -- disable help window resizing
opt.winwidth = 30 -- Minimum width for active window
opt.winminwidth = 1 -- Minimum width for inactive windows
opt.winheight = 1 -- Minimum height for active window
opt.winminheight = 1 -- Minimum height for inactive window
-- opt.pumblend = 0 -- Popup blend
-- opt.pumheight = 10 -- Maximum number of items to show in the popup menu

opt.showbreak = [[↪ ]] -- Options include -> '…', '↳ ', '→','↪ '

opt.listchars = {
  eol = nil,
  tab = '  ', -- Alternatives: '▷▷',
  extends = '…', -- Alternatives: … » ›
  precedes = '░', -- Alternatives: … « ‹
  conceal = '',
  nbsp = '␣',
  trail = '•', -- BULLET (U+2022, UTF-8: E2 80 A2)
}

opt.synmaxcol = 1024 -- don't syntax highlight long lines
opt.signcolumn = 'yes:1'
opt.linebreak = true -- lines wrap at words rather than random characters

-- exclude usetab as we do not want to jump to buffers in already open tabs
-- do not use split or vsplit to ensure we don't open any new windows
opt.switchbuf = 'useopen,uselast'

opt.fillchars = {
  foldopen = '󰅀', -- 󰅀 
  foldclose = '', -- 󰅂 
  fold = ' ', -- ⸱
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋',
}

-- Folds
-- ===
-- unfortunately folding in (n)vim is a mess, if you set the fold level to start
-- at X then it will auto fold anything at that level, all good so far. If you then
-- try to edit the content of your fold and the foldmethod=manual then it will
-- recompute the fold which when using nvim-ufo means it will be closed again...
opt.foldlevelstart = 999
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldtext = ''

-- Emoji
-- ===
-- emoji is true by default but makes (n)vim treat all emoji as double width
-- which breaks rendering so we turn this off.
-- CREDIT: https://www.youtube.com/watch?v=F91VWOelFNE
opt.emoji = false

opt.cursorlineopt = { 'both' }

-- Jumplist
-- ===
opt.jumpoptions = { 'stack' } -- make the jumplist behave like a browser stack

vim.opt.dictionary = require('sys').base .. '/misc/dictionary/english.txt' -- Use specific dictionaries
