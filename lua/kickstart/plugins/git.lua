local function find_git_root(dir)
  -- Find the nearest .git directory upward from 'dir'
  local git_dir = vim.fn.finddir('.git', dir .. ';')
  if git_dir and git_dir ~= '' then
    return vim.fn.fnamemodify(git_dir, ':h')
  else
    return dir
  end
end

local function open_neogit()
  local file_dir = vim.fn.expand '%:p:h'
  local target_dir = find_git_root(file_dir)
  if target_dir and target_dir ~= '' then
    vim.cmd('cd ' .. target_dir)
  end
  vim.cmd 'Neogit'
end

local function open_local_history()
  local file_dir = vim.fn.expand '%:p:h'
  local target_dir = find_git_root(file_dir)
  if target_dir and target_dir ~= '' then
    vim.cmd('cd ' .. target_dir)
  end
  vim.cmd 'LocalHistoryToggle'
end

return {
  -- Gitsigns configuration
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions: Visual mode
        map('v', '<leader>gs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>gr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [r]eset hunk' })
        -- Actions: Normal mode
        map('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>gb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>gd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>gD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = '[T]oggle git show [D]eleted' })
      end,
    },
  },

  -- Neogit configuration
  {
    'TimUntersberger/neogit',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('neogit').setup {
        integrations = {
          diffview = true, -- Integrate with diffview.nvim if desired
        },
      }
      -- Key mapping: Open Neogit UI with directory change
      vim.api.nvim_set_keymap('n', '<leader>gn', '', {
        noremap = true,
        silent = true,
        callback = open_neogit,
        desc = 'Open Neogit after cd to Git root',
      })
    end,
  },

  -- vim-local-history configuration
  {
    'dinhhuy258/vim-local-history',
    config = function()
      -- Configure plugin variables
      vim.g.local_history_enabled = 1 -- Enable the plugin
      vim.g.local_history_path = vim.fn.stdpath 'data' .. '/local-history'
      vim.g.local_history_max_changes = 12 -- Keep only the last 12 snapshots per file
      vim.g.local_history_new_change_delay = 300 -- Delay (sec) to prevent too many snapshots
      vim.g.local_history_autosave = 0 -- Disable autosave; only save on :write

      -- Auto-delete snapshots older than 24 hours on VimEnter
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          local history_dir = vim.g.local_history_path
          local max_age = 86400 -- 24 hours in seconds
          for _, file in ipairs(vim.fn.glob(history_dir .. '/*', true, true)) do
            local last_modified = vim.fn.getftime(file)
            if last_modified > 0 and (vim.fn.localtime() - last_modified) > max_age then
              os.remove(file)
            end
          end
        end,
      })

      -- Clear all local history after a Git commit
      vim.api.nvim_create_autocmd('User', {
        pattern = 'GitCommitPost',
        callback = function()
          local history_dir = vim.g.local_history_path
          for _, file in ipairs(vim.fn.glob(history_dir .. '/*', true, true)) do
            os.remove(file)
          end
          print 'Local history cleared after Git commit!'
        end,
      })

      -- Key mapping: Open Local History UI with directory change
      vim.api.nvim_set_keymap('n', '<leader>gl', '', {
        noremap = true,
        silent = true,
        callback = open_local_history,
        desc = 'Open Local History after cd to Git root',
      })
    end,
  },
}
