local fn, stdpath = vim.fn, vim.fn.stdpath

local homedir = vim.loop.os_homedir() .. '/'

local config_dirs = {
  'backup',
  'undo',
  'session',
}

local sys = {
  open_command = 'xdg-open',

  ---BSD'|'Linux'|'OSX'|'Other'|'POSIX'...
  name = jit.os:lower(),

  ---$HOME
  home = homedir,

  ---$HOME/.config/nvim
  base = stdpath 'config',

  ---$HOME/.local/share/nvim
  data = stdpath 'data',

  ---$HOME/.cache/nvim
  cache = stdpath 'cache' .. '/',

  ---$HOME/.dotfiles
  dotfiles = fn.expand '~/.dotfiles',

  ---$HOME/.projects
  projects = fn.expand '~/projects',

  package_package = stdpath('data') .. '/site',
  package_source = stdpath('config') .. '/src/',

  ---$HOME/.projects/woriook
  work = fn.expand '~/projects/work',

  ---$HOME/.local/state/nvim/swap
  swap = stdpath 'state' .. '/swap',

  ---Password file information
  user = vim.loop.os_get_passwd(),

  ---Returns a temporary path
  ---@param filename string
  ---@return string
  tmp = function(filename) return '/tmp/' .. filename end,

  ---Returns luajit version
  ---@return string
  luajit = function() return vim.split(jit.version, ' ')[2] end,

  ---@return boolean
  db_root = function()
    local root = stdpath 'data' .. '/databases'
    if fn.isdirectory(root) ~= 1 then fn.mkdir(root, 'p') end
    return root
  end,

  ---Checks if sqlite is supported
  ---@return boolean
  has_sqlite = function()
    local filereadable = function(filename) return fn.filereadable(filename) == 1 end
    local executable = function(exe) return fn.executable(exe) == 1 end
    if filereadable(homedir .. '/.local/lib/libsqlite.so') then
      vim.g.sqlite_clib_path = homedir .. '/.local/lib/libsqlite.so'
    end
    return executable 'sqlite3'
  end,

  ---Returns vim versions
  ---@return string[]

  version = function()
    return {
      vim.version().major,
      vim.version().minor,
      vim.version().patch,
    }
  end,
}

sys.user.name = sys.user.username
sys.username = sys.user.username

for _, dir_name in ipairs(config_dirs) do
  sys[dir_name] = sys.data .. '/' .. dir_name
end

return sys
