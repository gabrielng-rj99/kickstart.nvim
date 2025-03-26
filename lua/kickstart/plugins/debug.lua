-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well.

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    -- (Para Python, Java e outras linguagens, certifique-se de ter os adaptadores instalados via Mason ou manualmente)
    'mfussenegger/nvim-dap-python',
    -- Para Kotlin, recomenda-se usar a mesma configuração do Java.
    -- Para Ruby, SQL e Bash, os adaptadores devem estar instalados no sistema.
  },
  keys = {
    -- Normal execution: Run current file with python3 using F5.
    {
      '<F5>',
      function()
        local filepath = vim.fn.expand '%:p'
        vim.cmd('split | terminal python3 ' .. filepath)
      end,
      desc = 'Run: Execute current file normally',
    },
    -- Debugging: Start/Continue debugging with Ctrl+F5.
    {
      '<F29>',
      function()
        require('dapui').open()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
    -- Para HTML: abrir visualização do arquivo (ajusta o comando conforme seu SO)
    {
      '<leader>hp',
      ':!xdg-open %<CR>',
      desc = 'HTML: Open file preview',
      mode = 'n',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Uncomment these lines if you want DAP UI to automatically open/close with the session
    -- dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    -- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    -- dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Python adapter configuration: Adjusts command based on virtualenv presence
    require('dap').adapters.python = {
      type = 'python',
      request = 'launch',
      name = 'Launch file',
      command = function()
        local venv_path = os.getenv 'VIRTUAL_ENV'
        if venv_path then
          return venv_path .. '/bin/python'
        else
          return '/usr/bin/python3'
        end
      end,
      cwd = '${workspaceFolder}',
      program = '${file}',
      pythonPath = function()
        return '/usr/bin/python3'
      end,
    }

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        -- Atualize conforme os adaptadores que deseja instalar
        'delve', -- Go
        'python', -- Python
        'java', -- Java (e Kotlin)
        'node2', -- JavaScript/TypeScript
        'cppdbg', -- C, C++, Rust (usando o mesmo adapter)
        'netcoredbg', -- C#
        'php', -- PHP
        'bashdb', -- Bash
      },
    }

    -- Dap UI setup
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Go adapter configuration
    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- JavaScript/TypeScript (using node2)
    dap.adapters.node2 = {
      type = 'executable',
      command = 'node',
      args = { os.getenv 'HOME' .. '/.vscode-node-debug2/out/src/nodeDebug.js' },
    }
    dap.configurations.javascript = {
      {
        type = 'node2',
        request = 'launch',
        name = 'Launch JS file',
        program = '${file}',
        cwd = '${workspaceFolder}',
      },
    }
    dap.configurations.typescript = dap.configurations.javascript

    -- C, C++ and Rust (using cppdbg)
    dap.adapters.cppdbg = {
      type = 'executable',
      command = '/path/to/cpptools/extension/debugAdapters/bin/OpenDebugAD7', -- adjust to your path
    }
    local cpp_config = {
      name = 'Launch file',
      type = 'cppdbg',
      request = 'launch',
      program = '${file}',
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
    }
    dap.configurations.c = { cpp_config }
    dap.configurations.cpp = { cpp_config }
    dap.configurations.rust = { cpp_config }

    -- C# (using coreclr)
    dap.adapters.coreclr = {
      type = 'executable',
      command = '/path/to/netcoredbg', -- adjust to your path
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        name = 'Launch C#',
        type = 'coreclr',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
      },
    }

    -- PHP adapter and configuration
    dap.adapters.php = {
      type = 'executable',
      command = 'php-debug-adapter', -- adjust if needed
    }
    dap.configurations.php = {
      {
        name = 'Listen for Xdebug',
        type = 'php',
        request = 'launch',
        port = 9003,
        pathMappings = { ['/var/www/html'] = '${workspaceFolder}' },
      },
    }

    -- Ruby adapter and configuration
    dap.adapters.ruby = {
      type = 'executable',
      command = 'readapt', -- adjust based on installed adapter
      args = {},
    }
    dap.configurations.ruby = {
      {
        name = 'Launch Ruby file',
        type = 'ruby',
        request = 'launch',
        program = '${file}',
        cwd = '${workspaceFolder}',
      },
    }

    -- SQL: Map key to open file (not typical debugging)
    vim.api.nvim_set_keymap('n', '<leader>sq', ':!xdg-open %<CR>', { noremap = true, silent = true })

    -- Bash (using bashdb)
    dap.adapters.bashdb = {
      type = 'executable',
      command = 'bash-debug-adapter', -- adjust if necessary
      args = {},
    }
    dap.configurations.sh = {
      {
        name = 'Launch Bash script',
        type = 'bashdb',
        request = 'launch',
        program = '${file}',
        cwd = '${workspaceFolder}',
      },
    }
  end,
}
