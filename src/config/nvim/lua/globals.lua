local fn, fs, api, cmd, fmt, uv, validate = vim.fn, vim.fs, vim.api, vim.cmd, string.format, vim.loop, vim.validate
local l = vim.log.levels

----------------------------------------------------------------------------------------------------
-- Utils
----------------------------------------------------------------------------------------------------

--- Autosize horizontal split to match its minimum content
--- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
---@param min_height number
---@param max_height number
function mines.adjust_split_height(min_height, max_height)
  api.nvim_win_set_height(0, math.max(math.min(fn.line '$', max_height), min_height))
end

---------------------------------------------------------------------------------
-- Quickfix and Location List
---------------------------------------------------------------------------------

mines.list = { qf = {}, loc = {} }

---@param list_type "loclist" | "quickfix"
---@return boolean
local function is_list_open(list_type)
  return vim.iter(fn.getwininfo()):find(function(win) return not mines.falsy(win[list_type]) end) ~= nil
end

local silence = { mods = { silent = true, emsg_silent = true } }

---@param callback fun(...)
local function preserve_window(callback, ...)
  local win = api.nvim_get_current_win()
  callback(...)
  if win ~= api.nvim_get_current_win() then cmd.wincmd 'p' end
end

function mines.list.qf.toggle()
  if is_list_open 'quickfix' then
    cmd.cclose(silence)
  elseif #fn.getqflist() > 0 then
    preserve_window(cmd.copen, silence)
  end
end

function mines.list.loc.toggle()
  if is_list_open 'loclist' then
    cmd.lclose(silence)
  elseif #fn.getloclist(0) > 0 then
    preserve_window(cmd.lopen, silence)
  end
end

-- @see: https://vi.stackexchange.com/a/21255
-- using range-aware function
function mines.list.qf.delete(buf)
  buf = buf or api.nvim_get_current_buf()
  local list = fn.getqflist()
  local line = api.nvim_win_get_cursor(0)[1]
  local mode = api.nvim_get_mode().mode
  if mode:match '[vV]' then
    local first_line = fn.getpos("'<")[2]
    local last_line = fn.getpos("'>")[2]
    list = vim.iter(ipairs(list)):filter(function(i) return i < first_line or i > last_line end)
  else
    table.remove(list, line)
  end
  -- replace items in the current list, do not make a new copy of it; this also preserves the list title
  fn.setqflist({}, 'r', { items = list })
  fn.setpos('.', { buf, line, 1, 0 }) -- restore current line
end
---------------------------------------------------------------------------------

---@param str string
---@param max_len integer
---@return string
function mines.truncate(str, max_len)
  assert(str and max_len, 'string and max_len must be provided')
  return api.nvim_strwidth(str) > max_len and str:sub(1, max_len) .. mines.ui.icons.misc.ellipsis or str
end

---Determine if a value of any type is empty
---@param item any
---@return boolean?
function mines.falsy(item)
  if not item then return true end
  local item_type = type(item)
  if item_type == 'boolean' then return not item end
  if item_type == 'string' then return item == '' end
  if item_type == 'number' then return item <= 0 end
  if item_type == 'table' then return vim.tbl_isempty(item) end
  return item ~= nil
end

--- Call the given function and use `vim.notify` to notify of any errors
--- this function is a wrapper around `xpcall` which allows having a single
--- error handler for all errors
---@param msg string
---@param func function
---@param ... any
---@return boolean, any
---@overload fun(func: function, ...): boolean, any
function mines.pcall(msg, func, ...)
  local args = { ... }
  if type(msg) == 'function' then
    local arg = func --[[@as any]]
    args, func, msg = { arg, unpack(args) }, msg, nil
  end
  return xpcall(func, function(err)
    msg = debug.traceback(msg and fmt('%s:\n%s\n%s', msg, vim.inspect(args), err) or err)
    vim.schedule(function() vim.notify(msg, l.ERROR, { title = 'ERROR' }) end)
  end, unpack(args))
end

local LATEST_NIGHTLY_MINOR = 10
function mines.nightly() return vim.version().minor >= LATEST_NIGHTLY_MINOR end

----------------------------------------------------------------------------------------------------
--  FILETYPE HELPERS
----------------------------------------------------------------------------------------------------

---@class FiletypeSettings
---@field g table<string, any>
---@field bo vim.bo
---@field wo vim.wo
---@field opt vim.opt
---@field plugins {[string]: fun(module: table)}

---@param args {[1]: string, [2]: string, [3]: string, [string]: boolean | integer}[]
---@param buf integer
local function apply_ft_mappings(args, buf)
  vim.iter(args):each(function(m)
    assert(#m == 3, 'map args must be a table with at least 3 items')
    local opts = vim.iter(m):fold({ buffer = buf }, function(acc, key, item)
      if type(key) == 'string' then acc[key] = item end
      return acc
    end)
    map(m[1], m[2], m[3], opts)
  end)
end

--- A convenience wrapper that calls the ftplugin config for a plugin if it exists
--- and warns me if the plugin is not installed
---@param configs table<string, fun(module: table)>
function mines.ftplugin_conf(configs)
  if type(configs) ~= 'table' then return end
  for name, callback in pairs(configs) do
    local ok, plugin = mines.pcall(require, name)
    if ok then callback(plugin) end
  end
end

--- This function is an alternative API to using ftplugin files. It allows defining
--- filetype settings in a single place, then creating FileType autocommands from this definition
---
--- e.g.
--- ```lua
---   mines.filetype_settings({
---     lua = {
---      opt = {foldmethod = 'expr' },
---      bo = { shiftwidth = 2 }
---     },
---    [{'c', 'cpp'}] = {
---      bo = { shiftwidth = 2 }
---    }
---   })
--- ```
---
---@param map {[string|string[]]: FiletypeSettings | {[integer]: fun(args: AutocmdArgs)}}
function mines.filetype_settings(map)
  local commands = vim.iter(map):map(function(ft, settings)
    local name = type(ft) == 'table' and table.concat(ft, ',') or ft
    return {
      pattern = ft,
      event = 'FileType',
      desc = ('ft settings for %s'):format(name),
      command = function(args)
        vim.iter(settings):each(function(key, value)
          if key == 'opt' then key = 'opt_local' end
          if key == 'mappings' then return apply_ft_mappings(value, args.buf) end
          if key == 'plugins' then return mines.ftplugin_conf(value) end
          if type(key) == 'function' then return mines.pcall(key, args) end
          vim.iter(value):each(function(option, setting) vim[key][option] = setting end)
        end)
      end,
    }
  end)
  mines.augroup('filetype-settings', unpack(commands:totable()))
end

----------------------------------------------------------------------------------------------------
-- API Wrappers
----------------------------------------------------------------------------------------------------
-- Thin wrappers over API functions to make their usage easier/terser

local autocmd_keys = { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }
--- Validate the keys passed to mines.augroup are valid
---@param name string
---@param command Autocommand
local function validate_autocmd(name, command)
  local incorrect = vim.iter(command):map(function(key, _)
    if not vim.tbl_contains(autocmd_keys, key) then return key end
  end)
  if #incorrect > 0 then
    vim.schedule(function()
      local msg = ('Incorrect keys: %s'):format(table.concat(incorrect, ', '))
      vim.notify(msg, 'error', { title = ('Autocmd: %s'):format(name) })
    end)
  end
end

---@class AutocmdArgs
---@field id number autocmd ID
---@field event string
---@field group string?
---@field buf number
---@field file string
---@field match string | number
---@field data any

---@class Autocommand
---@field desc string?
---@field event  (string | string[])? list of autocommand events
---@field pattern (string | string[])? list of autocommand patterns
---@field command string | fun(args: AutocmdArgs): boolean?
---@field nested  boolean?
---@field once    boolean?
---@field buffer  number?

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string The name of the autocommand group
---@param ... Autocommand A list of autocommands to create
---@return number
function mines.augroup(name, ...)
  local commands = { ... }
  assert(name ~= 'User', 'The name of an augroup CANNOT be User')
  assert(#commands > 0, fmt('You must specify at least one autocommand for %s', name))
  local id = api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == 'function'
    api.nvim_create_autocmd(autocmd.event, {
      group = name,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

--- @class CommandArgs
--- @field args string
--- @field fargs table
--- @field bang boolean,

---Create an nvim command
---@param name string
---@param rhs string | fun(args: CommandArgs)
---@param opts table?
function mines.command(name, rhs, opts)
  opts = opts or {}
  api.nvim_create_user_command(name, rhs, opts)
end

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function mines.has(feature) return fn.has(feature) > 0 end

---@generic T
---Given a table return a new table which if the key is not found will search
---all the table's keys for a match using `string.match`
---@param map T
---@return T
function mines.p_table(map)
  return setmetatable(map, {
    __index = function(tbl, key)
      if not key then return end
      for k, v in pairs(tbl) do
        if key:match(k) then return v end
      end
    end,
  })
end

----------------------------------------------------------------------------------------------------
-- Files
----------------------------------------------------------------------------------------------------

mines.getcwd = uv.cwd

function mines.forward_path(path) return path end

function mines.buf_get_name(buf) return vim.api.nvim_buf_get_name(0) end

function mines.get_current_file_path() return mines.buf_get_name(vim.api.nvim_get_current_buf()) end

function mines.normalize(path)
  validate { path = { path, 'string' } }
  assert(path ~= '', debug.traceback 'Empty path')
  if path == '%' then
    local cwd = ((uv.cwd() .. '/'):gsub('\\', '/'):gsub('/+', '/'))
    path = (vim.api.nvim_buf_get_name(0):gsub(vim.pesc(cwd), ''))
  end
  return fs.normalize(path)
end

function mines.exists(filename)
  validate { filename = { filename, 'string' } }
  if filename == '' then return false end
  local stat = uv.fs_stat(mines.normalize(filename))
  return stat and stat.type or false
end

function mines.is_dir(filename) return mines.exists(filename) == 'directory' end

function mines.is_file(filename) return mines.exists(filename) == 'file' end

function mines.mkdir(dirname, recurive)
  validate {
    dirname = { dirname, 'string' },
    recurive = { recurive, 'boolean', true },
  }
  assert(dirname ~= '', debug.traceback 'Empty dirname')
  if mines.is_dir(dirname) then return true end
  dirname = mines.normalize(dirname)
  local ok, msg, err = uv.fs_mkdir(dirname, 511)
  if err == 'ENOENT' and recurive then
    local dirs = vim.split(dirname, '/' .. '+')
    local base = dirs[1] == '' and '/' or dirs[1]
    if dirs[1] == '' or mines.is_root(dirs[1]) then table.remove(dirs, 1) end
    for _, dir in ipairs(dirs) do
      base = base .. '/' .. dir
      if not mines.exists(base) then
        ok, msg, _ = uv.fs_mkdir(base, 511)
        if not ok then
          vim.notify(msg, 'ERROR', { title = 'Mkdir' })
          break
        end
      else
        ok = mines.is_dir(base)
        if not ok then break end
      end
    end
  elseif not ok then
    vim.notify(msg, 'ERROR', { title = 'Mkdir' })
  end
  return ok or false
end

function mines.link(src, dest, sym, force)
  validate {
    source = { src, 'string' },
    destination = { dest, 'string' },
    use_symbolic = { sym, 'boolean', true },
    force = { force, 'boolean', true },
  }
  assert(src ~= '', debug.traceback 'Empty source')
  assert(dest ~= '', debug.traceback 'Empty destination')
  assert(mines.exists(src), debug.traceback('link source ' .. src .. ' does not exists'))

  if dest == '.' then dest = fs.basename(src) end

  dest = mines.normalize(dest)
  src = mines.normalize(src)

  assert(src ~= dest, debug.traceback 'Cannot link src to itself')

  local status, msg, _

  if not sym and mines.is_dir(src) then
    vim.notify('Cannot hard link a directory', 'ERROR', { title = 'Link' })
    return false
  end

  if not force and mines.exists(dest) then
    vim.notify('Dest already exists in ' .. dest, 'ERROR', { title = 'Link' })
    return false
  elseif force and mines.exists(dest) then
    status, msg, _ = uv.fs_unlink(dest)
    if not status then
      vim.notify(msg, 'ERROR', { title = 'Link' })
      return false
    end
  end

  if sym then
    status, msg = uv.fs_symlink(src, dest, 438)
  else
    status, msg = uv.fs_link(src, dest)
  end

  if not status then vim.notify(msg, 'ERROR', { title = 'Link' }) end

  return status or false
end

function mines.executable(exec)
  validate { exec = { exec, 'string' } }
  assert(exec ~= '', debug.traceback 'Empty executable string')
  return fn.executable(exec) == 1
end

function mines.exepath(exec)
  validate { exec = { exec, 'string' } }
  assert(exec ~= '', debug.traceback 'Empty executable string')
  local path = fn.exepath(exec)
  return path ~= '' and path or false
end

function mines.is_absolute(path)
  validate { path = { path, 'string' } }
  assert(path ~= '', debug.traceback 'Empty path')
  if path:sub(1, 1) == '~' then path = path:gsub('~', uv.os_homedir()) end
  return path:sub(1, 1) == '/'
end

function mines.is_root(path)
  validate { path = { path, 'string' } }
  assert(path ~= '', debug.traceback 'Empty path')

  return path == '/'
end

function mines.realpath(path)
  validate { path = { path, 'string' } }
  assert(mines.exists(path), debug.traceback(([[Path "%s" doesn't exists]]):format(path)))
  return (uv.fs_realpath(mines.normalize(path)):gsub('\\', '/'))
end

function mines.basename(file)
  validate { file = { file, 'string', true } }
  if file == nil then return nil end
  return file:match '[/\\]$' and '' or (file:match('[^\\/]*$'):gsub('\\', '/'))
end

function mines.extension(path)
  validate { path = { path, 'string' } }
  assert(path ~= '', debug.traceback 'Empty path')
  local extension = ''
  path = mines.normalize(path)
  if not mines.is_dir(path) then
    local filename = mines.basename(path)
    extension = filename:match '^.+(%..+)$' or ''
  end
  return #extension >= 2 and extension:sub(2, #extension) or extension
end

function mines.filename(path)
  validate { path = { path, 'string' } }
  local name = fs.basename(path)
  local extension = mines.extension(name)
  return extension ~= '' and (name:gsub('%.' .. extension .. '$', '')) or name
end

function mines.dirname(file)
  validate { file = { file, 'string', true } }
  if file == nil then return nil end

  if not file:match '[\\/]' then
    return '.'
  elseif file == '/' or file:match '^/[^/]+$' then
    return '/'
  end
  local dir = file:match '[/\\]$' and file:sub(1, #file - 1) or file:match '^([/\\]?.+)[/\\]'
  return (dir:gsub('\\', '/'))
end

function mines.is_parent(parent, child)
  validate { parent = { parent, 'string' }, child = { child, 'string' } }
  assert(mines.is_dir(parent), debug.traceback(('Parent path is not a directory "%s"'):format(parent)))
  assert(mines.is_dir(child), debug.traceback(('Child path is not a directory "%s"'):format(child)))

  child = mines.realpath(child)
  parent = mines.realpath(parent)

  local is_child = false
  if mines.is_root(parent) or child:match('^' .. parent) then is_child = true end

  return is_child
end

function mines.openfile(path, flags, callback)
  validate {
    path = { path, 'string' },
    flags = { flags, 'string' },
    callback = { callback, 'function' },
  }
  assert(path ~= '', debug.traceback 'Empty path')

  local fd, msg, _ = uv.fs_open(path, flags, 438)
  if not fd then
    vim.notify(msg, 'ERROR', { title = 'OpenFile' })
    return false
  end
  local ok, rst = pcall(callback, fd)
  assert(uv.fs_close(fd))
  return rst or ok
end

local function fs_write(path, data, append, callback)
  validate {
    path = { path, 'string' },
    data = {
      data,
      function(d) return type(d) == type '' or vim.tbl_islist(d) end,
      'a string or an array',
    },
    append = { append, 'boolean', true },
    callback = { callback, 'function', true },
  }

  data = type(data) ~= type '' and table.concat(data, '\n') or data
  local flags = append and 'a+' or 'w+'

  if not callback then
    return mines.openfile(path, flags, function(fd)
      local stat = uv.fs_fstat(fd)
      local offset = append and stat.size or 0
      local ok, msg, _ = uv.fs_write(fd, data, offset)
      if not ok then vim.notify(msg, 'ERROR', { title = 'Write file' }) end
    end)
  end

  uv.fs_open(path, 'r+', 438, function(oerr, fd)
    assert(not oerr, oerr)
    uv.fs_fstat(fd, function(serr, stat)
      assert(not serr, serr)
      local offset = append and stat.size or 0
      uv.fs_write(fd, data, offset, function(rerr)
        assert(not rerr, rerr)
        uv.fs_close(fd, function(cerr)
          assert(not cerr, cerr)
          return callback()
        end)
      end)
    end)
  end)
end

function mines.writefile(path, data, callback) return fs_write(path, data, false, callback) end

function mines.updatefile(path, data, callback)
  assert(mines.is_file(path), debug.traceback('Not a file: ' .. path))
  return fs_write(path, data, true, callback)
end

function mines.readfile(path, split, callback)
  validate {
    path = { path, 'string' },
    callback = { callback, 'function', true },
    split = { split, 'boolean', true },
  }
  assert(mines.is_file(path), debug.traceback('Not a file: ' .. path))
  if split == nil then split = true end
  if not callback then
    return mines.openfile(path, 'r', function(fd)
      local stat = assert(uv.fs_fstat(fd))
      local data = assert(uv.fs_read(fd, stat.size, 0))
      if split then
        data = vim.split(data, '[\r]?\n')
        -- NOTE: This seems to always read an extra linefeed so we remove it if it's empty
        if data[#data] == '' then data[#data] = nil end
      end
      return data
    end)
  end
  uv.fs_open(path, 'r', 438, function(oerr, fd)
    assert(not oerr, oerr)
    uv.fs_fstat(fd, function(serr, stat)
      assert(not serr, serr)
      uv.fs_read(fd, stat.size, 0, function(rerr, data)
        assert(not rerr, rerr)
        uv.fs_close(fd, function(cerr)
          assert(not cerr, cerr)
          if split then
            data = vim.split(data, '[\r]?\n')
            if data[#data] == '' then data[#data] = nil end
          end
          return callback(data)
        end)
      end)
    end)
  end)
end

function mines.chmod(path, mode, base)
  validate {
    path = { path, 'string' },
    mode = {
      mode,
      function(m)
        local isnumber = type(m) == type(1)
        -- TODO: check for hex and bin ?
        local isrepr = type(m) == type '' and m ~= ''
        return isnumber or isrepr
      end,
      'valid integer representation',
    },
  }
  assert(path ~= '', debug.traceback 'Empty path')
  base = base == nil and 8 or base
  local ok, msg, _ = uv.fs_chmod(path, tonumber(mode, base))
  if not ok then vim.notify(msg, 'ERROR', { title = 'Chmod' }) end
  return ok or false
end

function mines.ls(path, opts)
  validate {
    path = { path, 'string' },
    opts = { opts, 'table', true },
  }
  opts = opts or {}

  local dir_it = uv.fs_scandir(path)
  local filename, ftype
  local results = {}

  repeat
    filename, ftype = uv.fs_scandir_next(dir_it)
    if filename and (not opts.type or opts.type == ftype) then table.insert(results, path .. '/' .. filename) end
  until not filename

  return results
end

function mines.get_files(path) return mines.ls(path, { type = 'file' }) end

function mines.get_dirs(path) return mines.ls(path, { type = 'directory' }) end

function mines.decode_json(data)
  validate {
    data = { data, { 'string', 'table' } },
  }
  if type(data) == type {} then data = table.concat(data, '\n') end
  return vim.json.decode(data)
end

function mines.encode_json(data)
  validate {
    data = { data, 'table' },
  }
  local json = vim.json.encode(data)
  return (json:gsub('\\/', '/'))
end

function mines.read_json(filename)
  validate {
    filename = { filename, 'string' },
  }
  assert(filename ~= '', debug.traceback 'Empty filename')
  if filename:sub(1, 1) == '~' then filename = filename:gsub('~', uv.os_homedir()) end
  assert(mines.is_file(filename), debug.traceback('Not a file: ' .. filename))
  return mines.decode_json(mines.readfile(filename, false))
end

function mines.dump_json(filename, data)
  validate { filename = { filename, 'string' }, data = { data, 'table' } }
  assert(filename ~= '', debug.traceback 'Empty filename')
  if filename:sub(1, 1) == '~' then filename = filename:gsub('~', uv.os_homedir()) end
  return mines.writefile(filename, mines.encode_json(data))
end

function mines.split(path) return vim.split(path, '/', { trimempty = true }) end

-- Credits: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua
-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
function mines.get_root()
  local root_patterns = { '.git', '.hg', '.bzr', '.svn' }

  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= '' and uv.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_active_clients { bufnr = 0 }) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws) return vim.uri_to_fname(ws.uri) end, workspace)
        or client.config.root_dir and { client.config.root_dir }
        or {}
      for _, p in ipairs(paths) do
        local r = uv.fs_realpath(p)
        if path:find(r, 1, true) then roots[#roots + 1] = r end
      end
    end
  end
  table.sort(roots, function(a, b) return #a > #b end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and fs.dirname(path) or uv.cwd()
    ---@type string?
    root = fs.find(root_patterns, { path = path, upward = true })[1]
    root = root and fs.dirname(root) or uv.cwd()
  end
  ---@cast root string
  return root
end

function mines.reload(pkg)
  package.loaded[pkg] = nil
  return require(pkg)
end

----------------------------------------------------------------------------------------------------
-- Git
----------------------------------------------------------------------------------------------------
function mines.is_git_repo(root)
  validate {
    root = { root, 'string' },
  }

  local is_file = mines.is_file
  local is_dir = mines.is_dir

  root = fs.normalize(root)
  local git = root .. '/.git'

  if is_dir(git) or is_file(git) then return git end
  local results = fs.find('.git', { path = root, upward = true })
  return #results > 0 and results[1] or false
end
