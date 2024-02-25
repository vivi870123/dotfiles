local prefixes = 'zx'
local labels = 'fgdsatrewquiopnmvcyb'

local function get_installed_plugins()
  local ok, lazy = pcall(require, 'lazy')
  if not ok then return 0 end
  return lazy.stats().count
end

local function recent_sessions()
  local sys = require 'sys'
  local sessions = require 'util.sessions'
  local home = sys.home

  local entries = {}

  for _, session in ipairs(sessions.recent_sessions()) do
    local name = sessions.get_session_cwd(session):gsub('^' .. home, '')

    table.insert(entries, {
      section = 'Recent sessions',
      name = name,
      action = function() sessions.load_session(session) end,
    })

    if #entries >= 10 then break end
  end
  return entries
end

local function index_items(content)
  local action_sections = { '' }
  local used_labels = {}
  local i_prefix = 0
  local i_label = 1

  local function use_label(label, prefix)
    local with_prefix = prefix .. label

    if not labels:find(label) or vim.tbl_contains(used_labels, with_prefix) then return nil end

    table.insert(used_labels, with_prefix)
    return with_prefix
  end

  local function get_label()
    local label = nil
    repeat
      local prefix = i_prefix > 0 and prefixes:sub(i_prefix, i_prefix) or ''
      label = use_label(labels:sub(i_label, i_label), prefix)

      i_label = i_label + 1
      if i_label > #labels then
        i_label = 1
        i_prefix = i_prefix + 1
      end
    until label or i_prefix > #prefixes

    return label
  end

  local coords = require('mini.starter').content_coords(content, 'item')

  for _, c in ipairs(coords) do
    local unit = content[c.line][c.unit]
    local item = unit.item

    local label = nil

    if vim.tbl_contains(action_sections, item.section) then
      local initial = item.name:sub(1, 1):lower()
      label = use_label(initial, '') or use_label(initial:upper(), '')
    end

    label = label or get_label()

    if label then unit.string = label .. '  ' .. unit.string end
  end
  return content
end

local logo = [[
                                              
       ████ ██████           █████      ██
      ███████████             █████ 
      █████████ ███████████████████ ███   ███████████
     █████████  ███    █████████████ █████ ██████████████
    █████████ ██████████ █████████ █████ █████ ████ █████
  ███████████ ███    ███ █████████ █████ █████ ████ █████
 ██████  █████████████████████ ████ █████ █████ ████ ██████
 ]]

return {
  'echasnovski/mini.starter',
  event = 'VimEnter',
  config = function()
    local starter = require 'mini.starter'
    local f = string.format

    local installed_plugins = f(' %d plugins installed', get_installed_plugins())
    local v = vim.version() or {}
    local version = f(' v%d.%d.%d %s', v.major, v.minor, v.patch, v.prerelease and '(nightly)' or '')
    local header = string.format('%s \n\t\t %s %s', logo, installed_plugins, version)

    starter.setup {
      evaluate_single = true,
      header = header,
      footer = '\n' .. require('plugins.mini.starter.quotes').cowsay(),
      items = {
        { section = 'Main', name = 'Find file', action = 'Pick files' },
        { section = 'Main', name = 'New File', action = 'enew' },
        { section = 'Main', name = 'Quit', action = 'qa' },

        -- Use this if you set up 'mini.sessions'
        starter.sections.sessions(5, true),

        starter.sections.recent_files(5, false),
      },
      content_hooks = {
        starter.gen_hook.padding(57, 4),
        starter.gen_hook.adding_bullet '  ',
        index_items,
      },
      query_updaters = prefixes .. labels,
    }
  end,
}

