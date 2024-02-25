if not mines then return end

local fn, api, uv, cmd, fmt = vim.fn, vim.api, vim.loop, vim.cmd, string.format
local augroup, command = mines.augroup, mines.command
local abbr = require('util.abbrs').set

local sys = require 'sys'

local recursive_map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.remap = true
  map(mode, lhs, rhs, opts)
end

local nmap = function(...) recursive_map('n', ...) end
local imap = function(...) recursive_map('i', ...) end
local nnoremap = function(...) map('n', ...) end
local xnoremap = function(...) map('x', ...) end
local vnoremap = function(...) map('v', ...) end
local inoremap = function(...) map('i', ...) end
local onoremap = function(...) map('o', ...) end
local cnoremap = function(...) map('c', ...) end
local tnoremap = function(...) map('t', ...) end

-----------------------------------------------------------------------------
-- Abbreviations
-----------------------------------------------------------------------------
abbr { mode = 'c', lhs = 'Gti', rhs = 'Git' }
abbr { mode = 'c', lhs = 'W', rhs = 'w' }
abbr { mode = 'c', lhs = 'Wq', rhs = 'wq' }
abbr { mode = 'c', lhs = 'WQ', rhs = 'wq' }
abbr { mode = 'c', lhs = 'Q', rhs = 'q' }
abbr { mode = 'c', lhs = 'q1', rhs = 'q!' }
abbr { mode = 'c', lhs = 'qa1', rhs = 'qa!' }
abbr { mode = 'c', lhs = 'w1', rhs = 'w!' }
abbr { mode = 'c', lhs = 'wA!', rhs = 'wa!' }
abbr { mode = 'c', lhs = 'wa1', rhs = 'wa!' }
abbr { mode = 'c', lhs = 'Qa1', rhs = 'qa!' }
abbr { mode = 'c', lhs = 'Qa!', rhs = 'qa!' }
abbr { mode = 'c', lhs = 'QA!', rhs = 'qa!' }

-----------------------------------------------------------------------------
-- Terminal
-----------------------------------------------------------------------------
augroup('AddTerminalMappings', {
  event = { 'TermOpen' },
  pattern = { 'term://*' },
  command = function()
    if vim.bo.filetype == '' or vim.bo.filetype == 'toggleterm' then
      local opts = { silent = false, buffer = 0 }
      tnoremap('<esc>', [[<C-\><C-n>]], opts)
      tnoremap('<C-h>', '<Cmd>wincmd h<CR>', opts)
      tnoremap('<C-j>', '<Cmd>wincmd j<CR>', opts)
      tnoremap('<C-k>', '<Cmd>wincmd k<CR>', opts)
      tnoremap('<C-l>', '<Cmd>wincmd l<CR>', opts)
      tnoremap(']t', '<Cmd>tablast<CR>')
      tnoremap('[t', '<Cmd>tabnext<CR>')
      tnoremap('<S-Tab>', '<Cmd>bprev<CR>')
      tnoremap('<leader><Tab>', '<Cmd>close \\| :bnext<cr>')
    end
  end,
})

-----------------------------------------------------------------------------
-- MACROS
-----------------------------------------------------------------------------
-- Absolutely fantastic function from stoeffel/.dotfiles which allows you to
-- repeat macros across a visual range
------------------------------------------------------------------------------
xnoremap('@', function()
  vim.ui.input({ prompt = 'Macro Register: ' }, function(reg) cmd([['<,'>normal @]] .. reg) end)
end, { silent = false })

-- Enter key should repeat the last macro recorded or just act as enter
nnoremap('<leader><CR>', [[empty(&buftype) ? '@@' : '<CR>']], { expr = true })

-----------------------------------------------------------------------------
-- Arrows
-----------------------------------------------------------------------------
nnoremap('<down>', '<nop>')
nnoremap('<up>', '<nop>')
nnoremap('<left>', '<nop>')
nnoremap('<right>', '<nop>')
inoremap('<up>', '<nop>')
inoremap('<down>', '<nop>')
inoremap('<left>', '<nop>')
inoremap('<right>', '<nop>')

nnoremap(',', ':')
xnoremap(',', ':')

-- Start an external command with a single bang
map('n', '!', ':!', { nowait = true })

-- Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap('Y', 'y$')
xnoremap('$', '$h')
xnoremap('<BS>', '<ESC>')

-----------------------------------------------------------------------------
-- Folds Related
-----------------------------------------------------------------------------
-- Evaluates whether there is a fold on the current line if so unfold it else return a normal space
nnoremap('<space><space>', [[@=(foldlevel('.')?'za':"\<Space>")<CR>]])
-- nnoremap('<cr>', [[@=(foldlevel('.')?'za':"\<Space>")<CR>]])

-- Focus the current fold by closing all others
nmap('<S-Return>', 'zMzv', { desc = 'Focus Fold' })

-- Refocus folds
nnoremap('<localleader><space>', [[zMzvzz]])

-- Make zO recursively open whatever top level fold we're in, no matter where the
-- cursor happens to be.
nnoremap('zO', [[zCzO]])

-- Toggle fold or select option from popup menu
nmap('<CR>', function() return fn.pumvisible() == 1 and '<CR>' or 'za' end, { expr = true, desc = 'Toggle Fold' })

------------------------------------------------------------------------------
-- Buffers
------------------------------------------------------------------------------
nnoremap('<localleader><tab>', [[:b <Tab>]], { silent = false, desc = 'open buffer list' })
nnoremap('<leader><leader>', [[<c-^>]], { desc = 'switch to last buffer' })

----------------------------------------------------------------------------------
-- Windows
----------------------------------------------------------------------------------
-- equivalent to gf but opens the window in a vertical split
-- vim doesn't have a native mapping for this as <C-w>f normally
-- opens a horizontal split
nnoremap('<C-w>f', '<C-w>vgf', { desc = 'open file in vertical split' })
-- make . work with visually selected lines
vnoremap('.', ':norm.<CR>')

-----------------------------------------------------------------------------//
-- Window bindings
-----------------------------------------------------------------------------//
-- https://vim.fandom.com/wiki/Fast_window_resizing_with_plus/minus_keys
if fn.bufwinnr(1) then
  nnoremap('<a-h>', '<C-W><')
  nnoremap('<a-l>', '<C-W>>')
end

-----------------------------------------------------------------------------
-- Window-control
-----------------------------------------------------------------------------
nnoremap('[Window]', '<Nop>')
nmap('s', '[Window]')

nnoremap('sb', '<cmd>buffer#<cr>', { desc = 'Alternate buffer' })
nnoremap('sc', '<cmd>close<CR>', { desc = 'Close window' })
nnoremap('st', '<cmd>tabnew<CR>', { desc = 'Buffer delete' })
nnoremap('sv', '<cmd>split<CR>', { desc = 'Split window horizontally' })
nnoremap('sg', '<cmd>vsplit<CR>', { desc = 'Split window vertically' })
nnoremap('sV', '<C-W>t <C-W>K', { desc = 'change two split windows to vsp' })
nnoremap('sG', '<C-W>t <C-W>H', { desc = 'change two vsp windows to splits' })
nnoremap('so', '<cmd>only<CR>', { desc = 'Close other windows' })

-- Background dark/light toggle
map('n', 'sh', function()
  if vim.o.background == 'dark' then
    vim.o.background = 'light'
  else
    vim.o.background = 'dark'
  end
end, { desc = 'Toggle background dark/light' })

-- Empty buffer but leave window
map('n', 'sx', function()
  require('mini.bufremove').delete(0, false)
  cmd.enew()
end, { desc = 'Delete buffer and open new' })

----------------------------------------------------------------------------------
-- Quick find/replace
----------------------------------------------------------------------------------
nnoremap('<leader>[', [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], {
  silent = false,
  desc = 'replace word under the cursor(file)',
})
nnoremap('<leader>]', [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], {
  silent = false,
  desc = 'replace word under the cursor (line)',
})
vnoremap('<leader>[', [["zy:%s/<C-r><C-o>"/]], {
  silent = false,
  desc = 'replace word under the cursor (visual)',
})

-- Visual shifting (does not exit Visual mode)
vnoremap('<', '<gv')
vnoremap('>', '>gv')

--Remap back tick for jumping to marks more quickly back
nnoremap("'", '`')

nnoremap('sn', [[:e <C-R>=expand("%:p:h") . "/" <CR>]], {
  silent = false,
  desc = 'Open a new file in the same directory',
})

nnoremap(
  'sf',
  [[:vsp <C-R>=expand("%:p:h") . "/" <CR>]],
  { silent = false, desc = 'Split to a new file in the same directory' }
)

----------------------------------------------------------------------------------
-- Commandline mappings
----------------------------------------------------------------------------------
-- <C-A> allows you to insert all matches on the command line e.g. bd *.js <c-a>
-- will insert all matching files e.g. :bd a.js b.js c.js
cnoremap('<c-x><c-a>', '<c-a>')

cnoremap('<C-k>', '<left>')
cnoremap('<C-j>', '<right>')

cnoremap('<C-r><C-w>', "<C-r>=escape(expand('<cword>'), '#')<CR>")
cnoremap('<C-r><C-n>', [[<C-r>=v:lua.vim.fs.basename(nvim_buf_get_name(0))<CR>]])
cnoremap('<C-r><C-p>', [[<C-r>=bufname('%')<CR>]])
cnoremap('<C-r><C-d>', [[<C-r>=v:lua.vim.fs.dirname(bufname('%'))..'/'<CR>]])

-- move cursor one character backwards unless at the end of the command line
cnoremap('<C-f>', function()
  if fn.getcmdpos() == fn.strlen(fn.getcmdline()) then return '<c-f>' end
  return '<Right>'
end, { expr = true })
cnoremap('<C-a>', '<Home>')
cnoremap('<C-b>', '<Left>')
cnoremap('<C-d>', '<Del>')

cmd.cabbrev('options', 'vert options')

----------------------------------------------------------------------------------
-- Core navigation
----------------------------------------------------------------------------------
-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
nnoremap('0', "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", { expr = true })
-- when going to the end of the line in visual mode ignore whitespace characters
vnoremap('$', 'g_')
-- Toggle top/center/bottom
nmap('zz', [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']], { expr = true })

-----------------------------------------------------------------------------//
-- Open Common files
-----------------------------------------------------------------------------//
local function edit(file) return fmt('<cmd>edit %s<cr>', file) end

nnoremap('<leader>ev', edit '$MYVIMRC', { desc = 'open $VIMRC' })
nnoremap('<leader>ez', edit '$ZDOTDIR/.zshrc', { desc = 'open zshrc' })
nnoremap('<leader>et', edit '$XDG_CONFIG_HOME/tmux/tmux.conf', { desc = 'open tmux.conf' })
nnoremap('<leader>ep', edit(fmt('%s/lua/plugins/init.lua', sys.base)), { desc = 'open plugins file' })
nnoremap('<leader>ep', edit(fmt('%s/.local/src/dwl/config.h', sys.home)), { desc = 'open dwl config' })
nnoremap('<leader>eS', edit(fmt('%s/.local/src/somebar/src/config.hpp', sys.home)), { desc = 'open somebar config' })
nnoremap('<leader>es', edit(fmt('%s/.local/src/someblocks/blocks.h', sys.home)), { desc = 'open someblocks config' })
nnoremap('<leader>yf', ":let @*=expand('%:p')<CR>", { desc = 'yank file path into the clipboard' })

----------------------------------------------------------------------------------
-- Grep Operator
----------------------------------------------------------------------------------
-- http://travisjeffery.com/b/2011/10/m-x-occur-for-vim/
---@param type string
---@return nil
function mines.mappings.grep_operator(type)
  local saved_unnamed_register = fn.getreg '@@'
  if type:match 'v' then
    cmd [[normal! `<v`>y]]
  elseif type:match 'char' then
    cmd [[normal! `[v`]y']]
  else
    return
  end
  -- Store the current window so if it changes we can restore it
  local win = api.nvim_get_current_win()
  cmd.grep { fn.shellescape(fn.getreg '@@') .. ' .', bang = true, mods = { silent = true } }
  fn.setreg('@@', saved_unnamed_register)
  if api.nvim_get_current_win() ~= win then cmd.wincmd 'J' end
end

nnoremap('gs', function()
  vim.o.operatorfunc = 'v:lua.mines.mappings.grep_operator'
  return 'g@'
end, { expr = true, desc = 'grep operator' })
xnoremap('gs', ':call v:lua.mines.mappings.grep_operator(visualmode())<CR>')

nnoremap('gF', '<Cmd>e <cfile><CR>')

----------------------------------------------------------------------------------
nnoremap('<leader>ls', mines.list.qf.toggle, { desc = 'toggle quickfix list' })
nnoremap('<leader>ll', mines.list.loc.toggle, { desc = 'toggle location list' })
nnoremap('=q', mines.list.qf.toggle, { desc = 'toggle quickfix list' })
nnoremap('=l', mines.list.loc.toggle, { desc = 'toggle location list' })

nnoremap(']q', '<cmd>cnext<CR>', { desc = 'Next Quickfix Item' })
nnoremap('[q', '<cmd>cprev<CR>', { desc = 'Previous Quickfix Item' })
nnoremap(']a', '<cmd>lnext<CR>', { desc = 'Next Loclist Item' })
nnoremap('[a', '<cmd>lprev<CR>', { desc = 'Previous Loclist Item' })

command('ClearRegisters', function()
  local regs = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-'
  for r in regs:gmatch '.' do
    fn.setreg(r, {})
  end
end)
