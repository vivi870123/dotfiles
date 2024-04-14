if vim.g.vscode then return end

if vim.loader then vim.loader.enable() end

local sys = require 'sys'
----------------------------------------------------------------------------------------------------
-- Global namespace
----------------------------------------------------------------------------------------------------

local namespace = {
  ui = {
    winbar = { enable = false },
    statuscolumn = { enable = true },
    statusline = { enable = true },
    tabline = { enable = true },
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


_G.RELOAD = function(pkg)
  if vim then
    if vim.is_thread() then
      package.loaded[pkg] = nil
    elseif vim.v.vim_did_enter == 1 then
      package.loaded[pkg] = nil
      if vim.loader and vim.loader.enabled then vim.loader.reset(pkg) end
    end
  else
    package.loaded[pkg] = nil
  end
  return require(pkg)
end

----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
-- Order matters here as globals needs to be instantiated first etc.
require 'globals'
require 'highlights'
require 'ui'
require 'settings'
require 'util.mini'

local lazypath = sys.data .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
  vim.notify 'Installed lazy.nvim'
end
vim.opt.runtimepath:prepend(lazypath)

-- If opening from inside neovim terminal then do not load other plugins
if vim.env.NVIM then return require('lazy').setup { { 'willothy/flatten.nvim', config = true } } end

-- Start lazy.nvim plugin manager.
require('lazy').setup {
  spec = {
    { import = 'plugins' },
  },
  lockfile = sys.data .. '/lazy-lock.json', -- lockfile generated after running update.
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
  ui = { border = mines.ui.current.border },
  diff = { cmd = 'terminal_git' },
  performance = {
    rtp = {
      paths = { sys.data .. '/site' },
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
vim.cmd.packadd 'cfilter'

------------------------------------------------------------------------------------------------------
-- Colour Scheme {{{1
------------------------------------------------------------------------------------------------------
mines.pcall('theme failed to load because', vim.cmd.colorscheme, 'kanagawa-lotus') -- night-owl
