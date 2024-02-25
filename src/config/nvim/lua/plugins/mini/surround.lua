return {
  'echasnovski/mini.surround',
  event = 'VeryLazy',
  keys = function(_, keys)
    -- Populate the keys based on the user's options
    local plugin = require('lazy.core.config').spec.plugins['mini.surround']
    local opts = require('lazy.core.plugin').values(plugin, 'opts', false)
    local mappings = {
      { opts.mappings.add, desc = 'Add surrounding', mode = { 'n', 'v' } },
      { opts.mappings.delete, desc = 'Delete surrounding' },
      { opts.mappings.find, desc = 'Find right surrounding' },
      { opts.mappings.find_left, desc = 'Find left surrounding' },
      { opts.mappings.highlight, desc = 'Highlight surrounding' },
      { opts.mappings.replace, desc = 'Replace surrounding' },
      { opts.mappings.update_n_lines, desc = 'Update `MiniSurround.config.n_lines`' },
    }
    mappings = vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings)
    return vim.list_extend(mappings, keys)
  end,
  opts = {
    custom_surroundings = {
      ['q'] = {
        input = {
          { '“().-()”', '‘().-()’' },
          { '“().-()”', '‘().-()’' },
        },
        output = { left = '“', right = '”' },
      },

      ['Q'] = {
        input = { '‘().-()’' },
        output = { left = '‘', right = '’' },
      },
    },
    mappings = {
      add = 'ys',
      delete = 'ds',
      find = '',
      find_left = '',
      highlight = '',
      replace = 'cs',
      update_n_lines = '',
      suffix_last = 'N',
      suffix_next = 'n',
    },
    n_lines = 50,
    search_method = 'cover_or_next',
  },
  config = function(_, opts)
    require('mini.surround').setup(opts)

    vim.keymap.del('x', 'ys')
    -- Remap adding surrounding to Visual mode selection
    map('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { noremap = true })

    -- Make special mapping for "add surrounding for line"
    vim.keymap.set('n', 'yss', 'ys_', { remap = true })
    -----------------------------------------------------------------------------//
    -- Quotes
    -----------------------------------------------------------------------------//
    vim.keymap.set('n', [[<leader>"]], [[ciw"<c-r>""<esc>]], { desc = 'surround with double quotes' })
    vim.keymap.set('n', '<leader>`', [[ciw`<c-r>"`<esc>]], { desc = 'surround with backticks' })
    vim.keymap.set('n', "<leader>'", [[ciw'<c-r>"'<esc>]], { desc = 'surround with single quotes' })
    vim.keymap.set('n', '<leader>)', [[ciw(<c-r>")<esc>]], { desc = 'surround with parentheses' })
    vim.keymap.set('n', '<leader>}', [[ciw{<c-r>"}<esc>]], { desc = 'surround with curly braces' })

    mines.mini.configure_mini_module('surround', {
      custom_surroundings = {
        s = {
          input = { '%[%[().-()%]%]' },
          output = { left = '[[', right = ']]' },
        },
      },
    }, { filetype = 'lua' })
    mines.mini.configure_mini_module('surround', {
      custom_surroundings = {
        ['B'] = { -- Surround for bold
          input = { '%*%*().-()%*%*' },
          output = { left = '**', right = '**' },
        },
        ['I'] = { -- Surround for italics
          input = { '%*().-()%*' },
          output = { left = '*', right = '*' },
        },
        ['L'] = {
          input = { '%[().-()%]%([^)]+%)' },
          output = function()
            local href = require('mini.surround').user_input 'Href'
            return {
              left = '[',
              right = '](' .. href .. ')',
            }
          end,
        },
      },
    }, { filetype = 'markdown' })
    mines.mini.configure_mini_module('surround', {
      custom_surroundings = {
        l = {
          input = { '%[%[().-()%]%]' },
          output = { left = '[[', right = ']]' },
        },
      },
    }, { filetype = 'org' })
  end,
}
