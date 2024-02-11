local fn = vim.fn
local border, highlight, L = mines.ui.current.border, mines.highlight, vim.log.levels

local routes = {
  {
    view = 'vsplit',
    filter = { event = 'msg_show', min_height = 20 },
  },
  {
    view = 'notify',
    filter = {
      any = {
        { event = 'msg_show', min_height = 10 },
        { event = 'msg_show', find = 'Treesitter' },
      },
    },
    opts = { timeout = 10000 },
  },
  {
    view = 'notify',
    filter = { event = 'notify', find = 'Type%-checking' },
    opts = { replace = true, merge = true, title = 'TSC' },
    stop = true,
  },
  {
    view = 'mini',
    filter = {
      any = {
        { event = 'msg_show', find = '^E486:' },
        { event = 'notify', max_height = 1 },
      },
    }, -- minimise pattern not found messages
  },
  {
    view = 'notify',
    filter = {
      any = {
        { warning = true },
        { event = 'msg_show', find = '^Warn' },
        { event = 'msg_show', find = '^W%d+:' },
        { event = 'msg_show', find = '^No hunks$' },
      },
    },
    opts = { title = 'Warning', level = L.WARN, merge = false, replace = false },
  },
  {
    view = 'notify',
    opts = { title = 'Error', level = L.ERROR, merge = true, replace = false },
    filter = {
      any = {
        { error = true },
        { event = 'msg_show', find = '^Error' },
        { event = 'msg_show', find = '^E%d+:' },
      },
    },
  },
  {
    view = 'notify',
    opts = { title = '' },
    filter = { kind = { 'emsg', 'echo', 'echomsg' } },
  },
}

-- filter annoying messages
local hidden_text = {
  '%[w%]',
  'written',
  'fewer lines',
  'line less',
  '%d+ changes?;',
  'more lines?',
  'yanked',
  '%d+ lines?',
  'search_count',
  -- 'No information available',
}

for _, msg in ipairs(hidden_text) do
  table.insert(routes, {
    filter = {
      event = 'msg_show',
      kind = '',
      find = msg,
    },
    opts = { skip = true },
  })
end

return {
  'folke/noice.nvim',
  enabled = true,
  event = 'VeryLazy',
  dependencies = { 'MunifTanjim/nui.nvim' },
  keys = {
    {
      '<c-f>',
      function()
        if not require('noice.lsp').scroll(4) then return '<c-f>' end
      end,
      mode = { 'n', 'i', 's' },
      silent = true,
      expr = true,
    },
    {
      '<c-b>',
      function()
        if not require('noice.lsp').scroll(-4) then return '<c-b>' end
      end,
      mode = { 'n', 'i', 's' },
      silent = true,
      expr = true,
    },
    {
      '<leader>nd',
      function() require('noice').cmd 'dismiss' end,
      desc = 'Noice: Dismiss notifications',
      mode = { 'n', 's' },
    },
    {
      '<M-CR>',
      function() require('noice').redirect(fn.getcmdline()) end,
      desc = 'redirect Cmdline',
      mode = 'c',
    },
  },
  opts = {
    messages = {
      -- NOTE: If you enable messages, then the cmdline is enabled automatically.
      -- This is a current Neovim limitation.
      enabled = true, -- enables the Noice messages UI
      view = 'notify', -- default view for messages
      view_error = 'notify', -- view for errors
      view_warn = 'notify', -- view for warnings
      view_history = 'messages', -- view for :messages
      view_search = 'virtualtext', -- view for search count messages. Set to `false` to disable
    },
    notify = {
      enabled = true,
      view = 'notify',
    },
    cmdline = {
      view = 'cmdline',
      format = {

        IncRename = { title = ' Rename ' },
        substitute = { pattern = '^:%%?s/', icon = ' ', ft = 'regex', title = '' },
        input = { icon = ' ', lang = 'text', view = 'cmdline_popup', title = '' },
      },
    },
    popupmenu = { backend = 'nui' },
    lsp = {
      progress = { enabled = false },
      documentation = {
        opts = {
          border = { style = border },
          position = { row = 2 },
        },
      },
      signature = {
        enabled = true,
        opts = {
          position = { row = 2 },
        },
      },
      hover = {
        enabled = true,
        silent = true,
      },
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
        ['vim.lsp.util.stylize_markdown'] = false,
        ['cmp.entry.get_documentation'] = true,
      },
    },
    views = {
      vsplit = { size = { width = 'auto' } },
      split = {
        win_options = {
          winhighlight = { Normal = 'Normal' },
        },
      },
      popup = {
        border = {
          style = border,
          padding = { 0, 1 },
        },
      },
      cmdline_popup = {
        position = { row = 5, col = '50%' },
        size = { width = 'auto', height = 'auto' },
        border = { style = border, padding = { 0, 1 } },
      },
      confirm = {
        border = {
          style = border,
          padding = { 0, 1 },
          text = { top = '' },
        },
      },
      popupmenu = {
        relative = 'editor',
        size = { width = 45, height = 10 },
        border = { style = border },
        win_options = {
          winhighlight = {
            Normal = 'NormalFloat',
            FloatBorder = 'FloatBorder',
          },
        },
      },
    },
    redirect = {
      view = 'popup',
      filter = { event = 'msg_show' },
    },
    presets = {
      bottom_search = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
    routes = routes,
  },
  config = function(_, opts)
    require('noice').setup(opts)

    highlight.plugin('noice', {
      { NoiceMini = { inherit = 'MsgArea', bg = { from = 'Normal' } } },
      { NoicePopupBaseGroup = { inherit = 'NormalFloat', fg = { from = 'DiagnosticSignInfo' } } },
      { NoicePopupWarnBaseGroup = { inherit = 'NormalFloat', fg = { from = 'Float' } } },
      { NoicePopupInfoBaseGroup = { inherit = 'NormalFloat', fg = { from = 'Conditional' } } },
      { NoiceCmdlinePopup = { bg = { from = 'NormalFloat' } } },
      { NoiceCmdlinePopupBorder = { link = 'FloatBorder' } },
      { NoiceCmdlinePopupTitle = { link = 'FloatTitle' } },
      { NoiceCmdlinePopupBorderCmdline = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlinePopupBorderSearch = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlinePopupBorderFilter = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlinePopupBorderHelp = { link = 'NoicePopupInfoBaseGroup' } },
      { NoiceCmdlinePopupBorderSubstitute = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlinePopupBorderIncRename = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlinePopupBorderInput = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlinePopupBorderLua = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlineIconCmdline = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlineIconSearch = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlineIconFilter = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlineIconHelp = { link = 'NoicePopupInfoBaseGroup' } },
      { NoiceCmdlineIconIncRename = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlineIconSubstitute = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlineIconInput = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlineIconLua = { link = 'NoicePopupBaseGroup' } },
      { NoiceConfirm = { bg = { from = 'NormalFloat' } } },
      { NoiceConfirmBorder = { link = 'NoicePopupBaseGroup' } },
    })
  end,
}
