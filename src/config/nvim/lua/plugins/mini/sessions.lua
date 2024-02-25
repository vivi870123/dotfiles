return {
  'echasnovski/mini.sessions',
  lazy = false,
  keys = {
    { "<leader>sd", function() require('mini.sessions').select "delete" end, desc = "Delete session" },
    { "<leader>ss", "<cmd>Pick read_session<cr>", desc = "Select session" },
    { "<leader>sw", function()
      vim.ui.input({
        prompt = "Session Name: ",
        default = vim.v.this_session ~= "" and vim.v.this_session or vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
      }, function(input)
        if input ~= nil then
          require('mini.sessions').write(input, { force = true })
        end
      end)
    end, desc = "Save session" },
    { "<leader>sx", function()
      if confirm_discard_changes() then
        vim.v.this_session = "" ---@diagnostic disable-line: inject-field
        vim.cmd "%bwipeout!"
        vim.cmd "cd ~"
      end
    end, desc = "Clear current session" }
  },
  opts = {}
}
