return {
  'echasnovski/mini.pick',
  event = 'VeryLazy',
  dependencies = {
    'echasnovski/mini.extra',
    'echasnovski/mini.fuzzy',
    'echasnovski/mini.visits',
    'echasnovski/mini.sessions',
  },
  keys = function()
    local function buffers()
      require('mini.pick').builtin.buffers({ include_current = false }, {
        mappings = {
          wipeout = {
            char = '<c-x>',
            func = function()
              local matches = require('mini.pick').get_picker_matches()
              if matches == nil then return end
              local removals = matches.marked
              if #removals == 0 then removals = { matches.current } end
              local result = {}
              for _, item in ipairs(matches.all) do
                if vim.tbl_contains(removals, item) then
                  vim.api.nvim_buf_delete(item.bufnr, {})
                else
                  table.insert(result, item)
                end
              end
              require('mini.pick').set_picker_items(result, { do_match = true })
            end,
          },
        },
      })
    end

    local function b(cmd) return string.format('<cmd>Pick %s<cr>', cmd) end

    return {
      { ',', b 'buf_lines scope="current"', nowait = true },
      { '<leader>,', buffers, desc = 'buffers' },
      { '<leader>.', b 'files', desc = 'files' },
      { '<leader>:', b 'commands', desc = 'commands' },

      { '<leader>fe', b 'explorer', desc = 'Find via file explorer' },
      { '<leader>fD', "m'<cmd>Pick lsp scope='declaration'<cr>", desc = 'Find LSP declaration' },
      { '<leader>fd', "m'<cmd>Pick lsp scope='definition'<cr>", desc = 'Find LSP definition' },
      { '<leader>ff', b 'files', desc = 'Find files' },
      { '<leader>gb', b 'git_branches', desc = 'Find branches' },
      { '<leader>gc', b 'git_commits', desc = 'Find commits' },
      { '<leader>gd', b 'git_files scope="deleted"', desc = 'Find deleted files' },
      { '<leader>gf', b 'git_files', desc = 'Find tracked files' },
      { '<leader>gh', b 'git_hunks', desc = 'Find hunks' },
      { '<leader>gi', b 'git_files scope="ignored"', desc = 'Find ignored files' },
      { '<leader>gm', b 'git_files scope="modified"', desc = 'Find modified files' },
      { '<leader>gu', b 'git_files scope="untracked"', desc = 'Find untracked files' },
      { '<leader>fG', b 'grep', desc = 'Find with grep' },
      { '<leader>fg', b 'grep_live', desc = 'Find with live grep' },
      { '<leader>fH', b 'hl_groups', desc = 'Find highlight groups' },
      { '<leader>fh', b 'help', desc = 'Find help documents' },
      { '<leader>fi', b 'diagnostic', desc = 'Find diagnostics' },
      { '<leader>fj', b 'list scope="jump"', desc = 'Find in jumplist' },
      { '<leader>fk', b 'keymaps', desc = 'Find keymaps' },
      { '<leader>fl', b 'buf_lines', desc = 'Find buffer lines' },
      { '<leader>fM', b 'marks', desc = 'Find marks' },
      { '<leader>fo', b 'options', desc = 'Find Neovim options' },
      { '<leader>fo', b 'oldfiles', desc = 'Find oldfiles' },
      { '<leader>fR', b 'registers', desc = 'Find registers' },
      { '<leader>fr', "m'<cmd>Pick lsp scope='references'<cr>", desc = 'Find LSP references' },
      { '<leader>fS', "m'<cmd>Pick lsp scope='workspace_symbol'<cr>", desc = 'Find LSP workspace symbol' },
      { '<leader>fs', "m'<cmd>Pick lsp scope='document_symbol'<cr>", desc = 'Find LSP document symbol' },
      { '<leader>fT', b 'treesitter', desc = 'Find treesitter nodes' },
      { '<leader>ft', b 'lsp scope="type_definition"', desc = 'Find LSP type definition' },
      { '<leader>fq', b 'list scope="quickfix"', desc = 'Find in quickfix list' },
      { '<leader>fw', b 'grep pattern="<cword>"', desc = 'Find current word' },
      { '<leader>fz', b 'spellsuggest', desc = 'Find spelling suggestions' },
      { '<localleader><localleader>', b 'frecency', desc = 'Select recent file' },
      { '<leader><C-r>', b 'resume', desc = 'resume' },
      { '<localleader>g', b 'grep', desc = 'grep' },
      { '<localleader>b', buffers, desc = 'buffers' },
      { '<localleader>H', b 'hl_groups', desc = 'highlights' },
      { '<leader>?', b 'help', desc = 'help' },
      { '<localleader>p', b 'registers', desc = 'registers' },
      { '<localleader>r', b 'resume', desc = 'resume last picker' },
      -- { 'z=', b 'spellsuggest n_suggestions=10', desc = 'spell suggest' },
      {
        'z=',
        function()
          if vim.v.count > 0 then ---@diagnostic disable-line: undefined-field
            vim.api.nvim_feedkeys(vim.v.count .. 'z=', 'n', false) ---@diagnostic disable-line: undefined-field
          else
            vim.cmd 'Pick spellsuggest'
          end
        end,
        desc = 'spelling suggestions',
      },
      -- { '<c-q>', b 'list scope="quickfix"', desc = 'quickfix' },
    }
  end,
  opts = function()
    return {
      mappings = {
        -- choose_alt = {
        --   char = "<nl>",
        --   func = function()
        --     vim.api.nvim_input "<cr>"
        --   end,
        -- },
        -- mark = "<c-space>",
        -- mark_and_move_down = {
        --   char = "<tab>",
        --   func = function()
        --     local mappings = MiniPick.get_picker_opts().mappings
        --     vim.api.nvim_input(mappings.mark .. mappings.move_down)
        --   end,
        -- },
        -- mark_and_move_up = {
        --   char = "<s-tab>",
        --   func = function()
        --     local mappings = MiniPick.get_picker_opts().mappings
        --     vim.api.nvim_input(mappings.mark .. mappings.move_up)
        --   end,
        -- },
        -- move_down_alt = {
        --   char = "<c-j>",
        --   func = function()
        --     local mappings = MiniPick.get_picker_opts().mappings
        --     vim.api.nvim_input(mappings.move_down)
        --   end,
        -- },
        -- refine = "<c-e>",
        toggle_info = '<c-/>',
        move_up = '<C-k>',
        move_down = '<C-j>',
        toggle_preview = '<tab>',
        quickfix = {
          char = '<c-q>',
          func = function()
            local items = MiniPick.get_picker_matches()
            if items == nil then return end
            if #items.marked > 0 then
              MiniPick.default_choose_marked(items.marked)
            else
              MiniPick.default_choose_marked(items.all)
            end
            MiniPick.stop()
          end,
        },
      },
    }
  end,
  config = function(_, opts)
    require('mini.pick').setup(opts)

    vim.ui.select = MiniPick.ui_select

    local MiniFuzzy = require 'mini.fuzzy'
    local MiniVisits = require 'mini.visits'

    MiniPick.registry.read_session = function()
      local items = vim.tbl_values(require('mini.sessions').detected)
      local current = vim.fn.fnamemodify(vim.v.this_session, ':t')
      table.sort(items, function(a, b)
        if a.name == current then
          return false
        elseif b.name == current then
          return true
        end
        return a.modify_time > b.modify_time
      end)
      for _, value in pairs(items) do
        value.text = value.name .. ' (' .. value.type .. ')'
      end
      local selection = MiniPick.start {
        source = {
          items = items,
          name = 'Read Session',
          choose = function() end,
        },
      }
      if selection ~= nil then
        if confirm_discard_changes() then require('mini.sessions').read(selection.name, { force = true }) end
      end
    end

    MiniPick.registry.frecency = function()
      local visit_paths = MiniVisits.list_paths()
      local current_file = vim.fn.expand '%'
      MiniPick.builtin.files(nil, {
        source = {
          match = function(stritems, indices, query)
            -- Concatenate prompt to a single string
            local prompt = vim.pesc(table.concat(query))

            -- If ignorecase is on and there are no uppercase letters in prompt,
            -- convert paths to lowercase for matching purposes
            local convert_path = function(str) return str end
            if vim.o.ignorecase and string.find(prompt, '%u') == nil then
              convert_path = function(str) return string.lower(str) end
            end

            local current_file_cased = convert_path(current_file)
            local paths_length = #visit_paths

            -- Flip visit_paths so that paths are lookup keys for the index values
            local flipped_visits = {}
            for index, path in ipairs(visit_paths) do
              local key = vim.fn.fnamemodify(path, ':.')
              flipped_visits[convert_path(key)] = index - 1
            end

            local result = {}
            for _, index in ipairs(indices) do
              local path = stritems[index]
              local match_score = prompt == '' and 0 or MiniFuzzy.match(prompt, path).score
              if match_score >= 0 then
                local visit_score = flipped_visits[path] or paths_length
                table.insert(result, {
                  index = index,
                  -- Give current file high value so it's ranked last
                  score = path == current_file_cased and 999999 or match_score + visit_score * 10,
                })
              end
            end

            table.sort(result, function(a, b) return a.score < b.score end)

            return vim.tbl_map(function(val) return val.index end, result)
          end,
        },
      })
    end
  end,
}
