local root = require 'lib.root'
local M = {}

-- A helper function to limit the size of a telescope window to fit the maximum available
-- space on the screen. This is useful for dropdowns e.g. the cursor or dropdown theme
local function fit_to_available_height(self, _, max_lines)
  local results, PADDING = #self.finder.results, 4 -- this represents the size of the telescope window
  local LIMIT = math.floor(max_lines / 2)
  return (results <= (LIMIT - PADDING) and results + PADDING or LIMIT)
end

---@param opts table?
---@return table
function M.cursor(opts)
  return require('telescope.themes').get_cursor(vim.tbl_extend('keep', opts or {}, {
    layout_config = {
      width = 0.4,
      height = fit_to_available_height,
    },
  }))
end

---@param opts table?
---@return table
function M.dropdown(opts)
  return require('telescope.themes').get_dropdown(vim.tbl_extend('keep', opts or {}, {
    borderchars = {
      prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
      results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    },
  }))
end

function M.adaptive_dropdown(_) return M.dropdown { height = fit_to_available_height } end

-- Custom window-sizes
---@param dimensions table
---@param size integer
---@return float
local function get_matched_ratio(dimensions, size)
  for min_cols, scale in pairs(dimensions) do
    if min_cols == 'lower' or size >= min_cols then return math.floor(size * scale) end
  end
  return dimensions.lower
end

function M.width_tiny(_, cols, _) return get_matched_ratio({ [180] = 0.27, lower = 0.37 }, cols) end
function M.width_small(_, cols, _) return get_matched_ratio({ [180] = 0.4, lower = 0.5 }, cols) end
function M.width_medium(_, cols, _) return get_matched_ratio({ [180] = 0.5, [110] = 0.6, lower = 0.75 }, cols) end
function M.width_large(_, cols, _) return get_matched_ratio({ [180] = 0.7, [110] = 0.8, lower = 0.85 }, cols) end

-- this will return a function that calls telescope.
-- cwd will default to lib.get_root
-- for `files`, git_files or find_files will be chosen depending on .git
---@param builtin string
---@param opts? lib.telescope.opts
function M.telescope(builtin, opts)
  local params = { builtin = builtin, opts = opts }
  return function()
    builtin = params.builtin
    opts = params.opts
    opts = vim.tbl_deep_extend('force', { cwd = root() }, opts or {}) --[[@as lib.telescope.opts]]
    if builtin == 'files' then
      if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. '/.git') then
        opts.show_untracked = true
        builtin = 'git_files'
      else
        builtin = 'find_files'
      end
    end
    if opts.cwd and opts.cwd ~= vim.loop.cwd() then
      ---@diagnostic disable-next-line: inject-field
      opts.attach_mappings = function(_, map)
        map('i', '<a-c>', function()
          local action_state = require 'telescope.actions.state'
          local line = action_state.get_current_line()
          M.telescope(
            params.builtin,
            vim.tbl_deep_extend('force', {}, params.opts or {}, { cwd = false, default_text = line })
          )()
        end)
        return true
      end
    end

    require('telescope.builtin')[builtin](opts)
  end
end

return M
