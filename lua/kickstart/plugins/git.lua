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

        -- Actions
        -- visual mode
        map('v', '<leader>gs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>gr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [r]eset hunk' })
        -- normal mode
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
          diffview = true, -- if you want to integrate with diffview.nvim
        },
        -- Other Neogit configurations can go here.
      }

      -- Keybinding for opening Neogit UI
      vim.api.nvim_set_keymap('n', '<leader>gn', ':Neogit<CR>', { noremap = true, silent = true })
    end,
  },

  -- Local History configuration
  {
    'dinhhuy258/vim-local-history',
    config = function()
      -- Configure plugin variables
      vim.g.local_history_path = vim.fn.stdpath 'data' .. '/local-history'
      vim.g.local_history_max_changes = 15 -- Keep only the last 15 snapshots per file
      vim.g.local_history_new_change_delay = 300 -- Delay (in seconds) to prevent too many snapshots (5 minutes)

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

      -- Keybinding for opening Local History
      vim.api.nvim_set_keymap('n', '<leader>gl', ':LocalHistory<CR>', { noremap = true, silent = true })
    end,
  },
}
