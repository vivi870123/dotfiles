local api = vim.api
local L = vim.lsp.log_levels

local function notify(msg) return vim.notify(msg, L.ERROR, { title = 'Nvim Abbrs' }) end

return {
  abbr = function(abbr)
    vim.validate { abbreviation = { abbr, 'table' } }
    if not abbr.mode or not abbr.lhs then
      notify 'Missing arguments!! set_abbr need a mode and a lhs attribbutes'
      return false
    end

    local command = {}
    local extras = {}

    local modes = {
      insert = 'i',
      command = 'c',
    }

    local lhs, rhs = abbr.lhs, abbr.rhs
    local args = type(abbr.args) == 'table' and abbr.args or { abbr.args }
    local mode = modes[abbr.mode] or abbr.mode

    if args.buffer ~= nil then table.insert(extras, '<buffer>') end

    if args.expr ~= nil and rhs ~= nil then table.insert(extras, '<expr>') end

    for _, v in pairs(extras) do
      table.insert(command, v)
    end

    if mode == 'i' or mode == 'insert' then
      if rhs == nil then
        table.insert(command, 1, 'iunabbrev')
        table.insert(command, lhs)
      else
        table.insert(command, 1, 'iabbrev')
        table.insert(command, lhs)
        table.insert(command, rhs)
      end
    elseif mode == 'c' or mode == 'command' then
      if rhs == nil then
        table.insert(command, 1, 'cunabbrev')
        table.insert(command, lhs)
      else
        table.insert(command, 1, 'cabbrev')
        table.insert(command, lhs)
        table.insert(command, rhs)
      end
    else
      notify('Unsupported mode: ' .. vim.inspect(mode))
      return false
    end

    if args.silent ~= nil then table.insert(command, 1, 'silent!') end

    api.nvim_command(table.concat(command, ' '))
  end,
}
