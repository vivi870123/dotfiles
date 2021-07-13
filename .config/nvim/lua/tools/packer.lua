local sys = require('sys')
local echomsg = require('tools.messages').echomsg
local fn = vim.fn
local fmt = string.format

local M = {}

function M.download_packer()
    local get_packer = function()
        local path = fmt('%s/site/pack/packer/opt/packer.nvim', fn.stdpath 'data')

        if fn.empty(fn.glob(path)) > 0 then

            local directory = string.format("%s/site/pack/packer/opt/", sys.data)

            fn.mkdir(directory, "p")

            install_path = directory .. "/packer.nvim"

            local out = fn.system(
                string.format("git clone %s %s", "https://github.com/wbthomason/packer.nvim", install_path)
            )

            echomsg(out)
            echomsg "Downloading packer.nvim..."
            echomsg "( You'll need to restart now )"
        end
    end

    return function()
        if not pcall(require, "packer") then
            get_packer()

            return true
        end

        return false
    end
end

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function M.has(feature)
  return vim.fn.has(feature) > 0
end


function M.compile()
    M.invalidate("plugins/packer", false)
    require("packer").compile()
    vim.notify "packer compiled..."
end

function M.invalidate(path, recursive)
  if recursive then
    for key, value in pairs(package.loaded) do
      if key ~= "_G" and value and vim.fn.match(key, path) ~= -1 then
        package.loaded[key] = nil
        require(key)
      end
    end
  else
    package.loaded[path] = nil
    require(path)
  end
end

local installed

---Check if a plugin is on the system not whether or not it is loaded
---@param plugin_name string
---@return boolean
function M.plugin_installed(plugin_name)
  if not installed then
    local dirs = fn.expand(sys.data .. "/site/pack/packer/start/*", true, true)
    local opt = fn.expand(sys.data .. "/site/pack/packer/opt/*", true, true)
    vim.list_extend(dirs, opt)
    installed = vim.tbl_map(function(path)
      return fn.fnamemodify(path, ":t")
    end, dirs)
  end
  return vim.tbl_contains(installed, plugin_name)
end

---NOTE: this plugin returns the currently loaded state of a plugin given
---given certain assumptions i.e. it will only be true if the plugin has been
---loaded e.g. lazy loading will return false
---@param plugin_name string
---@return boolean?
function M.plugin_loaded(plugin_name)
  local plugins = _G.packer_plugins or {}
  return plugins[plugin_name] and plugins[plugin_name].loaded
end

return M

