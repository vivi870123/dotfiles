local callbacks = {}

local M = {}

local function mini_autocmd(cmd, opts)
  if type(opts) == 'number' then opts = { buffer = opts } end

  if opts.filetype then
    if not callbacks.filetype then callbacks.filetype = {} end

    opts.filetype = type(opts.filetype) == 'string' and { opts.filetype } or opts.filetype

    for _, ft in pairs(opts.filetype) do
      if not callbacks.filetype[ft] then
        mines.augroup('MiniConfig', {
          event = 'FileType',
          pattern = ft,
          command = function(ev)
            for _, func in pairs(callbacks.filetype[ev.match]) do
              if type(func) == 'string' then
                vim.cmd(func)
              else
                func(ev)
              end
            end
          end,
        })

        callbacks.filetype[ft] = {}
      end
      table.insert(callbacks.filetype[ft], cmd)
    end
  end
  if opts.terminal then
    if not callbacks.terminal then
      mines.augroup('MiniConfig', {
        event = 'TermOpen',
        pattern = '*',
        command = function(ev)
          for _, func in pairs(callbacks.terminal) do
            if type(func) == 'string' then
              vim.cmd(func)
            else
              func(ev)
            end
          end
        end,
      })
      callbacks.terminal = {}
    end
    table.insert(callbacks.terminal, cmd)
  end
  if opts.buftype then
    if not callbacks.buftype then
      callbacks.buftype = {}

      mines.augroup('MiniConfig', {
        event = { 'BufNewFile', 'BufReadPost' },
        command = function(ev)
          if vim.tbl_contains(vim.tbl_keys(callbacks.buftype), vim.bo.buftype) then
            for _, func in pairs(callbacks.buftype[vim.bo.buftype]) do
              if type(func) == 'string' then
                vim.cmd(func)
              else
                func(ev)
              end
            end
          end
        end,
      })
    end
    opts.buftype = type(opts.buftype) == 'string' and { opts.buftype } or opts.buftype

    for _, bt in pairs(opts.buftype) do
      if not callbacks.buftype[bt] then callbacks.buftype[bt] = {} end
      table.insert(callbacks.buftype[bt], cmd)
    end
  end
end

function M.disable_mini_module(module, opts)
  if opts == nil then
    vim.g[string.format('mini%s_disable', module)] = true
    return
  end
  local var_name = string.format('b:mini%s_disable', module)
  local buf_disable = string.format('let %s = v:true', var_name)
  mini_autocmd(buf_disable, opts)
end

function M.configure_mini_module(module, config, opts)
  if type(config) == 'function' then config = config() end
  if opts == nil then require('mini.' .. module).setup(config or {}) end
  local callback = function() vim.b['mini' .. module .. '_config'] = config end
  mini_autocmd(callback, opts)
end

---Check if buffers are unsaved and prompt to save changes, continue without saving, or cancel operation
---@param all_buffers? boolean Check all buffers, or only current. Defaults to `true`
---@return boolean proceed `true` if OK to continue with action, `false` if user cancelled
function M.confirm_discard_changes(all_buffers)
  local buf_list = all_buffers == false and { 0 } or vim.api.nvim_list_bufs()
  local unsaved = vim.tbl_filter(
    function(buf_id) return vim.bo[buf_id].modified and vim.bo[buf_id].buflisted end,
    buf_list
  )

  if #unsaved == 0 then return true end

  for _, buf_id in ipairs(unsaved) do
    local name = vim.api.nvim_buf_get_name(buf_id)
    local result = vim.fn.confirm(
      string.format('Save changes to "%s"?', name ~= '' and vim.fn.fnamemodify(name, ':~:.') or 'Untitled'),
      '&Yes\n&No\n&Cancel',
      1,
      'Question'
    )

    if result == 1 then
      if buf_id ~= 0 then vim.cmd('buffer ' .. buf_id) end
      vim.cmd 'update'
    elseif result == 0 or result == 3 then
      return false
    end
  end

  return true
end

mines.mini = M
