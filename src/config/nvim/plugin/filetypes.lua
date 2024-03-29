if not mines then return end

local settings, highlight = mines.filetype_settings, mines.highlight
local cmd, fn = vim.cmd, vim.fn

vim.treesitter.language.register('gitcommit', 'NeogitCommitMessage')

settings {
  checkhealth = {
    opt = { spell = false },
  },
  ['dap-repl'] = {
    opt = {
      buflisted = false,
      winfixheight = true,
      signcolumn = 'yes:2',
    },
    function() mines.adjust_split_height(12, math.floor(vim.o.lines * 0.3)) end,
  },
  [{ 'gitcommit', 'gitrebase' }] = {
    bo = { bufhidden = 'delete' },
    opt = {
      list = false,
      spell = true,
      spelllang = 'en_gb',
    },
  },
  ['Neogit*'] = {
    wo = { winbar = '' },
  },
  NeogitCommitMessage = {
    opt = {
      spell = true,
      spelllang = 'en_gb',
      list = false,
    },
    plugins = {
      cmp = function(cmp)
        cmp.setup.filetype('NeogitCommitMessage', {
          sources = {
            { name = 'git', group_index = 1 },
            { name = 'luasnip', group_index = 1 },
            { name = 'dictionary', group_index = 1 },
            { name = 'spell', group_index = 1 },
            { name = 'buffer', group_index = 2 },
          },
        })
      end,
    },
    function()
      vim.schedule(function()
        -- Schedule this call as highlights are not set correctly if there is not a delay
        highlight.set_winhl('gitcommit', 0, { { VirtColumn = { fg = { from = 'Variable' } } } })
      end)
    end,
  },
  netrw = {
    g = {
      netrw_liststyle = 3,
      netrw_banner = 0,
      netrw_browse_split = 0,
      netrw_winsize = 25,
      netrw_altv = 1,
      netrw_fastbrowse = 0,
    },
    bo = { bufhidden = 'wipe' },
    mappings = {
      { 'n', 'q', '<Cmd>q<CR>' },
      { 'n', 'l', '<CR>' },
      { 'n', 'h', '<CR>' },
      { 'n', 'o', '<CR>' },
    },
  },
  norg = {
    plugins = {
      cmp = function(cmp)
        cmp.setup.filetype('norg', {
          sources = {
            { name = 'neorg', group_index = 1 },
            { name = 'dictionary', group_index = 1 },
            { name = 'spell', group_index = 1 },
            { name = 'emoji', group_index = 1 },
            { name = 'buffer', group_index = 2 },
          },
        })
      end,
      ['nvim-surround'] = function(surround)
        surround.buffer_setup {
          surrounds = {
            l = { add = function() return { { '[' }, { ']{' .. vim.fn.getreg '*' .. '}' } } end },
          },
        }
      end,
    },
  },
  org = {
    opt = {
      spell = true,
      signcolumn = 'yes',
    },
    plugins = {
      ufo = function(ufo) ufo.detach() end,
      cmp = function(cmp)
        cmp.setup.filetype('org', {
          sources = {
            { name = 'orgmode', group_index = 1 },
            { name = 'dictionary', group_index = 1 },
            { name = 'spell', group_index = 1 },
            { name = 'emoji', group_index = 1 },
            { name = 'buffer', group_index = 2 },
          },
        })
      end,
      ['nvim-surround'] = function(surround)
        surround.buffer_setup {
          surrounds = {
            l = {
              add = function() return { { ('[[%s]['):format(fn.getreg '*') }, { ']]' } } end,
            },
          },
        }
      end,
    },
  },
  [{ 'javascript', 'javascriptreact' }] = {
    bo = { textwidth = 100 },
    opt = { spell = true },
  },
  startuptime = {
    function() cmd.wincmd 'L' end, -- open startup time to the right
  },
  [{ 'typescript', 'typescriptreact' }] = {
    bo = { textwidth = 100 },
    opt = { spell = true },
    mappings = {
      { 'n', 'gd', '<Cmd>TypescriptGoToSourceDefinition<CR>', desc = 'typescript: go to source definition' },
    },
  },
  [{ 'lua', 'python', 'rust' }] = { opt = { spell = true } },
}
