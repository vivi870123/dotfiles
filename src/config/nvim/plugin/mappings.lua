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



