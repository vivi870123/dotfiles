if not mines then return end

local fn, api, v, env, cmd = vim.fn, vim.api, vim.v, vim.env, vim.cmd
local augroup, sys = mines.augroup, require 'sys'

----------------------------------------------------------------------------------------------------
-- Highlight Search
----------------------------------------------------------------------------------------------------
-- In order to get hlsearch working the way I like i.e. on when using /,?,N,n,*,#, etc. and off when
-- When I'm not using them, I need to set the following:
-- The mappings below are essentially faked user input this is because in order to automatically turn off
-- the search highlight just changing the value of 'hlsearch' inside a function does not work
-- read `:h nohlsearch`. So to have this workaround I check that the current mouse position is not a search
-- result, if it is we leave highlighting on, otherwise I turn it off on cursor moved by faking my input
-- using the expr mappings below.
--
-- This is based on the implementation discussed here:
-- https://github.com/neovim/neovim/issues/5581

map({ 'n', 'v', 'o', 'i', 'c' }, '<Plug>(StopHL)', 'execute("nohlsearch")[-1]', { expr = true })

local function stop_hl()
  if v.hlsearch == 0 or api.nvim_get_mode().mode ~= 'n' then return end
  api.nvim_feedkeys(vim.keycode '<Plug>(StopHL)', 'm', false)
end

local function hl_search()
  local col = api.nvim_win_get_cursor(0)[2]
  local curr_line = api.nvim_get_current_line()
  local ok, match = pcall(fn.matchstrpos, curr_line, fn.getreg '/', 0)
  if not ok then return end
  local _, p_start, p_end = unpack(match)
  -- if the cursor is in a search result, leave highlighting on
  if col < p_start or col > p_end then stop_hl() end
end

augroup(
  'VimrcIncSearchHighlight',
  { event = 'CursorMoved', command = function() hl_search() end },
  { event = 'InsertEnter', command = function() stop_hl() end },
  { event = 'RecordingEnter', command = function() vim.o.hlsearch = false end },
  { event = 'RecordingLeave', command = function() vim.o.hlsearch = true end },
  {
    event = 'OptionSet',
    pattern = 'hlsearch',
    command = function()
      vim.schedule(function() cmd.redrawstatus() end)
    end,
  }
)
