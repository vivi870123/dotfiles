return {
  'echasnovski/mini.bufremove',
  event = 'VeryLazy',
  keys = {
    { 'sx', function() require('mini.bufremove').delete(0, true) end, desc = 'Delete Buffer (Force)' },
  },
  config = function()
    -- :Bd[!] for layout-safe bufdelete
    mines.command('Bd', function(args) require('mini.bufremove').delete(0, not args.bang) end, { bang = true })
  end,
}
