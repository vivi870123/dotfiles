return {
  'echasnovski/mini.comment',
  event = 'VeryLazy',
  keys = {
    { '<c-/>', 'gcc', remap = true, silent = true, mode = 'n' },
    { '<c-/>', 'gc', remap = true, silent = true, mode = 'x' },
  },
  dependencies = {
    {
      'JoosepAlviste/nvim-ts-context-commentstring',
      init = function() vim.g.skip_ts_context_commentstring_module = true end,
    },
  },
  opts = {
    options = {
      custom_commentstring = function()
        return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
      end,
    },
    hooks = {
      pre = function() require('ts_context_commentstring.internal').update_commentstring {} end,
    },
  },
}
