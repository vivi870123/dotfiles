return {
  'echasnovski/mini.ai',
  -- event = { 'BufRead', 'BufNewFile' },
  opts = function()
    local gen_spec = require('mini.ai').gen_spec

    ---@return Pair #The Pair at the current cursor position
    local function make_point()
      local _, l, c, _ = unpack(vim.fn.getpos '.')
      return { line = l, col = c }
    end

    return {
      mappings = {
        around = 'a',
        inside = 'i',
        around_next = 'an',
        inside_next = 'in',
        around_last = 'al',
        inside_last = 'il',
        goto_left = 'g[',
        goto_right = 'g]',
      },

      n_lines = 500, -- Number of lines within which textobject is searched
      search_method = 'cover_or_next',
      custom_textobjects = {
        ['s'] = { { '%b()', '%b[]', '%b{}', '%b""', "%b''", '%b``' }, '^.().*().$' },
        m = gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
        c = gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
        a = gen_spec.treesitter { a = '@parameter.outer', i = '@parameter.inner' },
        o = gen_spec.treesitter {
          a = { '@conditional.outer', '@loop.outer' },
          i = { '@conditional.inner', '@loop.inner' },
        },
        x = gen_spec.treesitter { a = '@comment.outer', i = '@comment.inner' },

        E = function()
          local from = { line = 1, col = 1 }
          local to = {
            line = vim.api.nvim_buf_line_count(0),
            col = math.max(vim.fn.getline('$'):len(), 1),
          }
          return { from = from, to = to }
        end,

        u = { 'https?://[A-Za-z0-9][A-Za-z0-9_%-/.#?%%&=;@]+' },

        -- Folds
        z = function(type)
          vim.api.nvim_feedkeys('[z' .. (type == 'i' and 'j0' or ''), 'x', true)
          local from = make_point()
          vim.api.nvim_feedkeys(']z' .. (type == 'i' and 'k$' or '$'), 'x', true)
          local to = make_point()

          return { from = from, to = to }
        end,

        [','] = { -- Grammatically correct comma matching
          {
            '[%.?!][ ]*()()[^,%.?!]+(),[ ]*()', -- Start of sentence
            '(),[ ]*()[^,%.?!]+()()[%.?!][ ]*', -- End of sentence
            ',[ ]*()[^,%.?!]+(),[ ]*', -- Dependent clause
            '^()[A-Z][^,%.?!]+(),[ ]*', -- Start of line
          },
        },
      },
    }
  end,
  config = function(_, opts)
    require('mini.ai').setup(opts)

    local spec_pair = require('mini.ai').gen_spec.pair
    mines.mini.configure_mini_module('ai', {
      custom_textobjects = {
        ['*'] = spec_pair('*', '*', { type = 'greedy' }), -- Grab all asterisks when selecting
        ['_'] = spec_pair('_', '_', { type = 'greedy' }), -- Grab all underscores when selecting
        ['l'] = { '%b[]%b()', '^%[().-()%]%([^)]+%)$' }, -- Link targeting name
        ['L'] = { '%b[]%b()', '^%[.-%]%(()[^)]+()%)$' }, -- Link targeting href
      },
    }, { filetype = 'markdown' })
    mines.mini.configure_mini_module('ai', {
      custom_textobjects = {
        ['s'] = require('mini.ai').gen_spec.pair('[[', ']]'),
      },
    }, { filetype = 'lua' })
  end,
}

