---@diagnostic disable: missing-fields
-----------------------------------------------------------------------------//
-- Language servers
-----------------------------------------------------------------------------//
-- svelte requires the additional installation of the typescript-svelte-plugin, per project
-- https://github.com/sveltejs/language-tools/tree/master/packages/typescript-plugin#usage

---@type lspconfig.options
local servers = {
  sqlls = false,
  eslint = {},
  ccls = {},
  jsonls = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  },
  bashls = {},
  vimls = {},
  terraformls = {},
  marksman = {},
  pyright = {},
  bufls = {},
  prosemd_lsp = {},
  docker_compose_language_service = function()
    local lspconfig = require 'lspconfig'
    return {
      root_dir = lspconfig.util.root_pattern 'docker-compose.yml',
      filetypes = { 'yaml', 'dockerfile' },
    }
  end,
  graphql = {
    on_attach = function(client)
      -- Disable workspaceSymbolProvider because this prevents
      -- searching for symbols in typescript files which this server
      -- is also enabled for.
      -- @see: https://github.com/nvim-telescope/telescope.nvim/issues/964
      client.server_capabilities.workspaceSymbolProvider = false
    end,
  },
  --- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  yamlls = {
    settings = {
      yaml = {
        customTags = {
          '!reference sequence', -- necessary for gitlab-ci.yaml files
        },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        codeLens = { enable = false },
        hint = { enable = true, arrayIndex = 'Disable', setType = false, paramName = 'Disable', paramType = true },
        format = { enable = false },
        completion = { keywordSnippet = 'Replace', callSnippet = 'Replace' },
        diagnostics = {
          enable = false,
          workspaceDelay = -1,
        },
        workspace = {
          checkThirdParty = false,
          ignoreSubmodules = true,
        },
        telemetry = { enable = false },
      },
    },
  },
}

---Get the configuration for a specific language server
---@param name string?
---@return table<string, any>?
return function(name)
  local config = name and servers[name] or {}
  if not config then return end
  if type(config) == 'function' then config = config() end
  config.capabilities = vim.tbl_deep_extend('keep', config.capabilities or {}, {
    textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } },
  })
  return config
end
