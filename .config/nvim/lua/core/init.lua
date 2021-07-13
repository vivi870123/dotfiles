local disable_distribution_plugins= function()
	vim.g.loaded_gzip              = 1
	vim.g.loaded_tar               = 1
	vim.g.loaded_tarPlugin         = 1
	vim.g.loaded_zip               = 1
	vim.g.loaded_zipPlugin         = 1
	vim.g.loaded_getscript         = 1
	vim.g.loaded_getscriptPlugin   = 1
	vim.g.loaded_vimball           = 1
	vim.g.loaded_vimballPlugin     = 1
	vim.g.loaded_matchit           = 1
	vim.g.loaded_matchparen        = 1
	vim.g.loaded_2html_plugin      = 1
	vim.g.loaded_logiPat           = 1
	vim.g.loaded_rrhelper          = 1
	vim.g.loaded_netrw             = 1
	vim.g.loaded_netrwPlugin       = 1
	vim.g.loaded_netrwSettings     = 1
	vim.g.loaded_netrwFileHandlers = 1
end

local leader_map = function()
	vim.g.mapleader = " "
	vim.api.nvim_set_keymap('n',' ','',{noremap = true})
	vim.api.nvim_set_keymap('x',' ','',{noremap = true})
end


local init_vim =function()
    -- require "core.packer_init"
    require "tools".packer.download_packer()

    disable_distribution_plugins()
    leader_map()

    require('settings/python').setup()
    require('tools/globals')

    require('settings')

    require('plugins/packer')

    -- require('core.mapping')
    -- require('keymap')
    -- require('core.event')
end

init_vim()
