local filetypes = { "c", "cpp", "go", "java", "javascript", "lua", "php", "python", "ruby", "typescript" }

return { -- refactoring.nvim
  'ThePrimeagen/refactoring.nvim',
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  ft = filetypes,
  config = function()
    local refactor = require "refactoring"

    refactor.setup {}

    mines.augroup('RefactoringEvent', {
      event = 'FileType',
      pattern = filetypes,
      command = function(opts)
        local function map(mode, key, desc)
          vim.keymap.set(mode, key, function()
            refactor.refactor(desc)
          end, { desc = desc, buffer = opts.buf })
        end

        map("x", "<leader>rf", "Extract Function")
        map("x", "<leader>rF", "Extract Function To File")
        map("x", "<leader>rv", "Extract Variable")
        map("n", "<leader>rb", "Extract Block")
        map("n", "<leader>rB", "Extract Block To File")
        map("n", "<leader>rI", "Inline Function")
        map({ "n", "x" }, "<leader>ri", "Inline Variable")
      end,
    })
  end,
}
