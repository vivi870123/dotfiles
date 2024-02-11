if vim.g.vscode then return end -- if someone has forced me to use vscode don't load my config

local g, fn, loop, env, cmd = vim.g, vim.fn, vim.loop, vim.env, vim.cmd
local data = fn.stdpath 'data'

if vim.loader then vim.loader.enable() end

g.os = loop.os_uname().sysname
g.open_command = 'xdg-open'
g.dotfiles = env.DOTFILES or fn.expand '~/.dotfiles'
g.vim_dir = g.dotfiles .. '/.config/nvim'
g.projects_dir = env.PROJECTS_DIR or fn.expand '~/projects'
g.data_dir = data
g.cache_dir = fn.stdpath 'cache'
-- g.vim_runtime = '~/.asdf/installs/neovim/nightly/share/nvim/runtime'
g.db_root = function()
  local root = data .. '/databases'
  if vim.fn.isdirectory(root) ~= 1 then vim.fn.mkdir(root, 'p') end
  return root
end

g.tmp_dir = function(filename) return '/tmp/' .. filename end

----------------------------------------------------------------------------------------------------
-- Global namespace
----------------------------------------------------------------------------------------------------

local namespace = {
  ui = {
    winbar = { enable = false },
    statuscolumn = { enable = true },
    statusline = { enable = true },
  },
  -- some vim mappings require a mixture of commandline commands and function calls
  -- this table is place to store lua functions to be called in those mappings
  mappings = { enable = true },
}

-- This table is a globally accessible store to facilitating accessing
-- helper functions and variables throughout my config
_G.mines = mines or namespace
_G.map = vim.keymap.set
_G.P = vim.print

----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
-- Order matters here as globals needs to be instantiated first etc.
require 'util' -- Global
require 'highlights'
require 'ui'

----------------------------------------------------------------------------------------------------
-- Leader bindings
----------------------------------------------------------------------------------------------------
g.mapleader = ' ' -- Leader key
g.maplocalleader = ';' -- Local leader

------------------------------------------------------------------------------------------------------
-- Plugin Manager Download
------------------------------------------------------------------------------------------------------
local core = require 'core'
core.ensure_lazy()

----------------------------------------------------------------------------------------------------
--  $NVIM
----------------------------------------------------------------------------------------------------
-- NOTE: this must happen after the lazy path is setup
-- If opening from inside neovim terminal then do not load other plugins
if env.NVIM then return require('lazy').setup { { 'willothy/flatten.nvim', config = true } } end
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-- Plugin Manager Setup
------------------------------------------------------------------------------------------------------
-- Start lazy.nvim plugin manager.
require('lazy').setup {
  spec = {
    { import = 'plugins' },
    { import = 'plugins.mini' },
  },
  concurrency = vim.loop.available_parallelism() * 2,
  defaults = { lazy = true, version = false },
  install = { missing = true, colorscheme = {} },
  checker = {
    enabled = true,
    concurrency = 30,
    notify = false,
    frequency = 3600, -- check for updates every hour
  },
  change_detection = { notify = false },
  -- ui = { border = mines.ui.current.border },
  diff = { cmd = 'terminal_git' },
  performance = {
    rtp = {
      paths = { data .. '/site' },
      disabled_plugins = {
        'gzip',
        'vimballPlugin',
        'matchit',
        'matchparen',
        '2html_plugin',
        'tarPlugin',
        'netrwPlugin',
        'tutor',
        'zipPlugin',
      },
    },
  },
}

map('n', '<leader>pm', '<Cmd>Lazy<CR>', { desc = 'manage' })

------------------------------------------------------------------------------------------------------
-- Builtin Packages
------------------------------------------------------------------------------------------------------
-- cfilter plugin allows filtering down an existing quickfix list
cmd.packadd 'cfilter'

core.setup()
