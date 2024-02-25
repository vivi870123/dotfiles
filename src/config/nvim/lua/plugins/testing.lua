local fn, api, diagnostic = vim.fn, vim.api, vim.diagnostic

local function neotest() return require 'neotest' end
local function open() neotest().output.open { enter = true, short = false } end
local function run_file() neotest().run.run(fn.expand '%') end
local function run_file_sync() neotest().run.run { fn.expand '%', concurrent = false } end
local function nearest() neotest().run.run() end
local function next_failed() neotest().jump.prev { status = 'failed' } end
local function prev_failed() neotest().jump.next { status = 'failed' } end
local function toggle_summary() neotest().summary.toggle() end
local function cancel() neotest().run.stop { interactive = true } end

return {
  { -- vim-test
    'vim-test/vim-test',
  },
  { -- neotest
    'nvim-neotest/neotest',
    dependencies = {
      { 'nvim-neotest/neotest-vim-test' },
      { 'haydenmeade/neotest-jest' },
      { 'adalessa/neotest-phpunit' },
      { 'rcarriga/neotest-plenary', dependencies = { 'nvim-lua/plenary.nvim' } },
      { 'marilari88/neotest-vitest' },
      { 'thenbe/neotest-playwright' },
    },
    keys = {
      { '<localleader>ts', toggle_summary, desc = 'neotest: toggle summary' },
      { '<localleader>to', open, desc = 'neotest: output' },
      { '<localleader>tn', nearest, desc = 'neotest: run' },
      { '<localleader>tf', run_file, desc = 'neotest: run file' },
      { '<localleader>tF', run_file_sync, desc = 'neotest: run file synchronously' },
      { '<localleader>tc', cancel, desc = 'neotest: cancel' },
      { '[n', next_failed, desc = 'jump to next failed test' },
      { ']n', prev_failed, desc = 'jump to previous failed test' },
    },
    ft = { 'php', 'typescript', 'typescriptreact', 'lua' },
    config = function()
      local namespace = api.nvim_create_namespace 'neotest'
      diagnostic.config({
        virtual_text = {
          format = function(d) return d.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '') end,
        },
      }, namespace)

      local adapters = {
        require 'neotest-plenary',
        require 'neotest-vim-test' { ignore_file_types = { 'go', 'lua', 'rust', 'php' } },
        require 'neotest-jest' {
          jestCommand = 'npm test --',
          jestConfigFile = 'jest.config.js',
        },
        require 'neotest-vitest',
        require('neotest-playwright').adapter {
          options = {
            persist_project_selection = true,
            enable_dynamic_test_discovery = true,
          },
        },
      }

      require('neotest').setup {
        discovery = { enabled = true },
        diagnostic = { enabled = true },
        quickfix = { enabled = false, open = true },
        floating = { border = mines.ui.border },
        adapters = adapters,
      }
    end,
  },
}

