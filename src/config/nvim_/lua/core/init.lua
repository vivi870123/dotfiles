----------------------------------------------------------------------------------------------------
-- Defaults
----------------------------------------------------------------------------------------------------
local defaults = {
  -- Load the default settings
  -- stylua: ignore
  defaults = {
    autocommands = true, -- core.autocommands
    colors = true, -- core.colors
    env = true, -- core.env
    filetypes = true, -- core.filetypes
    keymaps = true,  -- core.keymaps
    lastplace = true,  -- core.lastplace
    lsp = true,  -- core.lsp
    numbers = true,  -- core.numbers
    statusline = true,  -- core.statusline

    -- core.settings can't be configured here since it's loaded
    -- prematurely. You can disable loading settings with the following line at
    -- the top of your lua/core/setup.lua or init.lua:
    -- `package.loaded['core.settings'] = true`
  },
}

local M = {}

M.lazy_version = '>=9.1.0'
M.renames = {}
M.did_init = false

function M.init()
  if not M.did_init then
    M.did_init = true
    -- delay notifications till vim.notify was replaced or after 500ms
    require('core').lazy_notify()

    -- load settings here, before lazy init while sourcing plugin modules
    -- this is needed to make sure settings will be correctly applied
    -- after installing missing plugins
    require('core').load 'settings'

    -- carry over plugin options that their name has been changed.
    local Plugin = require 'lazy.core.plugin'
    local add = Plugin.Spec.add
    ---@diagnostic disable-next-line: duplicate-set-field
    Plugin.Spec.add = function(self, plugin, ...)
      if type(plugin) == 'table' and M.renames[plugin[1]] then plugin[1] = M.renames[plugin[1]] end
      return add(self, plugin, ...)
    end
  end
end

local settings

-- Load config files.
function M.setup()
  if not M.did_init then M.init() end

  settings = vim.tbl_deep_extend('force', defaults, {})
  if not M.has_version() then
    require('lazy.core.util').error(
      string.format('**lazy.nvim** version %s is required.\n Please upgrade **lazy.nvim**', M.lazy_version)
    )
    error 'Exiting'
  end

  M.load 'lsp'
  M.load 'colors'
  M.load 'lastplace'
  M.load 'numbers'
  M.load 'autocommands'
  M.load 'keymaps'
  M.load 'filetypes'
  M.load 'env'
  M.load 'statusline'
end

---@param range? string
---@return boolean
function M.has_version(range)
  local Semver = require 'lazy.manage.semver'
  return Semver.range(range or M.lazy_version):matches(require('lazy.core.config').version or '0.0.0')
end

---@param name "autocommands" | "settings" | "keymaps" | "lsp" | "colors" | "lastplace" | "numbers" | "filetypes" | "env" | "statusline"
function M.load(name)
  local Util = require 'lazy.core.util'
  local function _load(mod)
    Util.try(function() require(mod) end, {
      msg = 'Failed loading ' .. mod,
      on_error = function(msg)
        local info = require('lazy.core.cache').find(mod)
        if info == nil or (type(info) == 'table' and #info == 0) then return end
        Util.error(msg)
      end,
    })
  end
  -- always load rafi's file, then user file
  if M.defaults[name] or name == 'settings' then _load('core.' .. name) end
  _load('core.' .. name)
  if vim.bo.filetype == 'lazy' then vim.cmd [[do VimResized]] end
end

-- Ensure package manager (lazy.nvim) exists.
function M.ensure_lazy()
  local lazypath = vim.g.data_dir .. '/lazy/lazy.nvim'
  if not vim.loop.fs_stat(lazypath) then
    print 'Installing lazy.nvim…'
    vim.fn.system {
      'git',
      'clone',
      '--filter=blob:none',
      '--branch=stable',
      'https://github.com/folke/lazy.nvim.git',
      lazypath,
    }
  end
  vim.opt.rtp:prepend(lazypath)
end

-- Delay notifications till vim.notify was replaced or after 500ms.
function M.lazy_notify()
  local notifs = {}
  local function temp(...) table.insert(notifs, vim.F.pack_len(...)) end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.loop.new_timer()
  local check = vim.loop.new_check()
  if timer == nil or check == nil then return end

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    vim.schedule(function()
      ---@diagnostic disable-next-line: no-unknown
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then replay() end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

setmetatable(M, {
  __index = function(_, key)
    if settings == nil then return vim.deepcopy(defaults)[key] end
    return settings[key]
  end,
})

return M
