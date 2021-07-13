local nvim = require('nvim')
local sys = require('sys')
local pack = require('tools').packer
local fmt = string.format

local PACKER_COMPILED_PATH = sys.cache .. "/packer/packer_compiled.vim"

local fn = vim.fn
local set_autocmd = nvim.autocmds.set_autocmd
local has = pack.has
local install_packer = pack.bootstrap_packer


--install_packer()
-----------------------------------------------------------------------------//
-- Bootstrap Packer {{{
-----------------------------------------------------------------------------//
-- Make sure packer is installed on the current machine and load
-- the dev or upstream version depending on if we are at work or not
-- NOTE: install packer as an opt plugin since it's loaded conditionally on my local machine
-- it needs to be installed as optional so the install dir is consistent across machines
local install_path = fmt("%s/site/pack/packer/opt/packer.nvim", fn.stdpath "data")
if fn.empty(fn.glob(install_path)) > 0 then
    vim.notify "Downloading packer.nvim..."
    vim.notify(
    fn.system { "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path }
    )
    vim.cmd "packadd! packer.nvim"
    require("packer").sync()
else
    local name = vim.env.DEVELOPING and "local-packer.nvim" or "packer.nvim"
    vim.cmd(fmt("packadd! %s", name))
end
-- }}}
-------
--
-- cfilter plugin allows filter down an existing quickfix list
vim.cmd "packadd! cfilter"

set_autocmd{
    event   = 'BufWritePost',
    pattern = '*/plugins/packer/plugins.lua',
    cmd     = [[lua require'tools.packer'.compile()]],
    group   = 'PackerAutocmds',
}

vim.cmd [[ nnoremap <leader>ps <Cmd>PackerSync<CR>]]
vim.cmd [[ nnoremap <leader>pc <Cmd>PackerClean<CR>]]


---Require a plugin config
---@param name string
---@return any
local function conf(name)
    return require(string.format("plugins.%s", name))
end

require("packer").startup {
    function(use, use_rocks)
        use { "wbthomason/packer.nvim", opt = true }
        --------------------------------------------------------------------------------

        use_rocks "penlight"

        use {
            "airblade/vim-rooter",
            config = function()
                vim.g.rooter_silent_chdir = 1
                vim.g.rooter_resolve_links = 1
            end,
        }
        use {
            "nvim-telescope/telescope.nvim",
            event = "CursorHold",
            config = conf "telescope",
            requires = {
                "nvim-lua/popup.nvim",
                { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
                {
                    "nvim-telescope/telescope-frecency.nvim",
                    requires = "tami5/sql.nvim",
                    after = "telescope.nvim",
                },
                { "camgraff/telescope-tmux.nvim" },
            },
        }

        use "kyazdani42/nvim-web-devicons"

        use { "folke/which-key.nvim", config = conf "whichkey" }
    end

}
