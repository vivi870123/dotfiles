local fn = vim.fn
local fmt = string.format
local sys = require('sys')
local echomsg = require('tools.messages').echomsg


local download_packer = function()
    local path = fmt('%s/site/pack/packer/opt/packer.nvim', fn.stdpath 'data')

    if fn.empty(fn.glob(path)) > 0 then

        local directory = string.format("%s/site/pack/packer/opt/", sys.data)

        fn.mkdir(directory, "p")

        install_path = directory .. "/packer.nvim"

        local out = fn.system(
        string.format("git clone %s %s", "https://github.com/wbthomason/packer.nvim", install_path)
        )

        echomsg(out)
        echomsg "Downloading packer.nvim..."
        echomsg "( You'll need to restart now )"
    end
end

return function()
    if not pcall(require, "packer") then
        download_packer()

        return true
    end

    return false
end
