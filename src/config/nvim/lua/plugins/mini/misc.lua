return {
  'echasnovski/mini.misc',
  lazy = false,
  keys = {
    { 'sz', '<cmd>lua MiniMisc.zoom()<cr>', desc = 'Zoom' },
  },
  config = function()
    require('mini.misc').setup()

    require('mini.misc').setup_auto_root {
      '.git',
      'Gemfile',
      'Makefile',
      'Rakefile',
      'package.json',
      'composer.json',
      'pyproject.toml',
      'setup.py',
    }

    require('mini.misc').setup_restore_cursor()
  end,
}
