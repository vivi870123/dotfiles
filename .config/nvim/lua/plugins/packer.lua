local nvim = require('nvim')
local fn = vim.fn
local fmt = string.format
local set_autocmd = nvim.autocmds.set_autocmd

local PACKER_COMPILED_PATH = fn.stdpath 'cache' .. '/packer/packer_compiled.lua'

vim.cmd [[packadd! packer.nvim]]
vim.cmd [[packadd vimball]]

-----------------------------------------------------------------------------//

-- check if a certain feature/version/commit exists in nvim
-- @param feature string
-- @return boolean
local has = function(feature)
    return vim.fn.has(feature) > 0
end

-- cfilter plugin allows filter down an existing quickfix list
vim.cmd 'packadd! cfilter'

set_autocmd{
  event   = 'BufWritePost',
  pattern = '*/plugins/packer.lua',
  cmd     = 'lua require"tools".packer.compile()',
  group   = 'TerminalAutocmds'
}

-- as.nnoremap('<leader>ps', [[<Cmd>PackerSync<CR>]])
-- as.nnoremap('<leader>pc', [[<Cmd>PackerClean<CR>]])


require('packer').startup {
  function(use, use_rocks)
    use { 'wbthomason/packer.nvim', opt = true }
    --------------------------------------------------------------------------------
    -- Core {{{
    ---------------------------------------------------------------------------------
    use_rocks 'penlight'

    use "nvim-lua/popup.nvim"
    use "nvim-lua/plenary.nvim"

    use {
      'airblade/vim-rooter',
      config = function()
        vim.g.rooter_silent_chdir = 1
        vim.g.rooter_resolve_links = 1
      end
    }

    use {
        'nvim-telescope/telescope.nvim',
        event = 'CursorHold',
        requires = {
            { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
            {
                'nvim-telescope/telescope-frecency.nvim',
                requires = 'tami5/sql.nvim',
                after = 'telescope.nvim',
            },
            'nvim-lua/popup.nvim',
            'nvim-telescope/telescope-packer.nvim',
            'camgraff/telescope-tmux.nvim',
            'nvim-telescope/telescope-cheat.nvim',
            {
                "nvim-telescope/telescope-arecibo.nvim",
                rocks = { "openssl", "lua-http-parser" }
            }
        }
    }

--    use {
--      'nvim-telescope/telescope.nvim',
--      event = 'CursorHold',
--      config = conf 'telescope',
--      requires = {
--        'nvim-lua/popup.nvim',
--        'nvim-telescope/telescope-packer.nvim',
--        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
--        {
--          'nvim-telescope/telescope-frecency.nvim',
--          requires = 'tami5/sql.nvim',
--          after = 'telescope.nvim',
--        },
--        { 'camgraff/telescope-tmux.nvim' },
--      },
--    }

    -- }}}
    ---------------------------------------------------------------------------------
  end,
  config = {
    compile_path = PACKER_COMPILED_PATH,
    display = {
      open_fn = require('packer.util').float,
    },
    profile = {
      enable = true,
      threshold = 1,
    },
  },
}

-- as.command {
--   'PackerCompiledEdit',
--   function()
--     vim.cmd(fmt('edit %s', PACKER_COMPILED_PATH))
--   end,
-- }
-- 
-- as.command {
--   'PackerCompiledDelete',
--   function()
--     vim.fn.delete(PACKER_COMPILED_PATH)
--     vim.notify(fmt('Deleted %s', PACKER_COMPILED_PATH))
--   end,
-- }

if not vim.g.packer_compiled_loaded and vim.loop.fs_stat(PACKER_COMPILED_PATH) then
  vim.cmd(fmt('source %s', PACKER_COMPILED_PATH))
  vim.g.packer_compiled_loaded = true
end
-- }}}

-- vim:foldmethod=marker
