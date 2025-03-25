-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

-- Helper function to find the git root directory
local function find_git_root(dir)
  -- vim.fn.finddir() searches upward when using the ';' separator.
  -- It returns the first matching path for ".git".
  local git_path = vim.fn.finddir('.git', dir .. ';')
  if git_path ~= '' then
    -- Remove the trailing "/.git" to return the git root directory.
    return vim.fn.fnamemodify(git_path, ':h')
  else
    return dir
  end
end

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    {
      'cd', -- Keybinding to open Neo-tree at the project root (if a .git folder is found) or file's directory
      function()
        local file_dir = vim.fn.expand '%:p:h'
        local target_dir = find_git_root(file_dir)
        vim.cmd('Neotree filesystem reveal dir=' .. target_dir)
      end,
      desc = 'NeoTree reveal relative to git root or file directory',
      silent = true,
    },
  },
  opts = {
    filesystem = {
      window = {
        width = 42, -- Set the desired width for the sidebar
        mappings = {
          ['\\'] = 'close_window',
          ['-'] = 'navigate_up', -- Go to the parent directory (like "..")
        },
      },
      filtered_items = {
        hide_dotfiles = false, -- Show hidden (dot) files
      },
    },
  },
}
