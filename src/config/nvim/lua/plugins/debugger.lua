local fn = vim.fn
local icons, highlight, palette = mines.ui.icons, mines.highlight, mines.ui.palette

return {
  {
    'mfussenegger/nvim-dap',
    keys = {
      {
        '<localleader>dL',
        function() require('dap').set_breakpoint(nil, nil, fn.input 'Log point message: ') end,
        desc = 'dap: log breakpoint',
      },
      { '<localleader>db', '<cmd>DapToggleBreakpoint<cr>', desc = 'dap: toggle breakpoint' },
      {
        '<localleader>dB',
        function() require('dap').set_breakpoint(fn.input 'Breakpoint condition: ') end,
        desc = 'dap: set conditional breakpoint',
      },
      { '<localleader>dc', '<cmd>DapContinue<cr>', desc = 'dap: continue or start debugging' },
      { '<localleader>duc', function() require('dapui').close() end, desc = 'dap ui: close' },
      { '<localleader>dut', function() require('dapui').toggle() end, desc = 'dap ui: toggle' },
      { '<localleader>dt', '<cmd>DapToggleRepl<cr>', desc = 'dap: toggle repl' },
      { '<localleader>de', '<cmd>DapStepOut<cr>', desc = 'dap: step out' },
      { '<localleader>di', '<cmd>DapStepInto<cr>', desc = 'dap: step into' },
      { '<localleader>do', '<cmd>DapStepOver<cr>', desc = 'dap: step over' },
      { '<localleader>dl', function() require('dap').run_last() end, desc = 'dap REPL: run last' },
    },
    dependencies = {
      { -- vscode-js-debug
        enabled = false,
        'microsoft/vscode-js-debug',
        build = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out',
      },
      { -- nvim-dap-ui
        'rcarriga/nvim-dap-ui',
        opts = {
          windows = { indent = 2 },
          floating = { border = mines.ui.current.border },
          layouts = {
            {
              elements = {
                { id = 'scopes', size = 0.25 },
                { id = 'breakpoints', size = 0.25 },
                { id = 'stacks', size = 0.25 },
                { id = 'watches', size = 0.25 },
              },
              position = 'left',
              size = 20,
            },
            {
              elements = {
                { id = 'repl', size = 0.9 },
              },
              position = 'bottom',
              size = 10,
            },
          },
        },
      },
      { -- nvim-dap-virtual-text
        'theHamsta/nvim-dap-virtual-text',
        opts = { all_frames = true },
      },
    },
    config = function()
      local dap = require 'dap' -- Dap must be loaded before the signs can be tweaked
      local ui_ok, dapui = pcall(require, 'dapui')

      highlight.plugin('dap', {
        { DapBreakpoint = { fg = palette.light_red } },
        { DapStopped = { fg = palette.green } },
      })

      fn.sign_define {
        { name = 'DapBreakpoint', text = icons.bug, texthl = 'DapBreakpoint', linehl = '', numhl = '' },
        { name = 'DapStopped', text = icons.bookmark, texthl = 'DapStopped', linehl = '', numhl = '' },
      }

      -- DON'T automatically stop at exceptions
      -- dap.defaults.fallback.exception_breakpoints = {}

      if not ui_ok then return end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end

      dap.adapters.php = { type = 'executable', command = 'php-debug-adapter' }
      dap.configurations.php = {
        {
          type = 'php',
          request = 'launch',
          name = 'Laravel',
          port = 9003,
          pathMappings = { ['/var/www/html'] = '${workspaceFolder}' },
        },
        {
          type = 'php',
          request = 'launch',
          name = 'Symfony',
          port = 9003,
          pathMappings = { ['/app'] = '${workspaceFolder}' },
        },
      }
    end,
  }, -- nvim-dap
  {
    'mxsdev/nvim-dap-vscode-js',
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    enabled = false,
    dependencies = { 'mfussenegger/nvim-dap' },
    opts = {
      adapters = { 'chrome', 'pwa-node', 'pwa-chrome', 'node-terminal', 'pwa-extensionHost' },
      node_path = 'node',
      debugger_cmd = { 'js-debug-adapter' },
    },
    config = function(_, opts)
      require('dap-vscode-js').setup(opts)

      for _, language in ipairs { 'typescript', 'javascript' } do
        require('dap').configurations[language] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
        }
      end

      for _, language in ipairs { 'typescriptreact', 'javascriptreact' } do
        require('dap').configurations[language] = {
          {
            type = 'pwa-chrome',
            name = 'Attach - Remote Debugging',
            request = 'attach',
            program = '${file}',
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            protocol = 'inspector',
            port = 9222,
            webRoot = '${workspaceFolder}',
          },
          {
            type = 'pwa-chrome',
            name = 'Launch Chrome',
            request = 'launch',
            url = 'http://localhost:3000',
          },
        }
      end
    end,
  }, -- nvim-dap-vscode-js
}

