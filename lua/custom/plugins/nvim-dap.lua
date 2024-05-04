return {
  { 'folke/neodev.nvim', opts = { library = { plugins = { 'nvim-dap-ui' }, types = true } } },
  {
    'rcarriga/nvim-dap-ui',
    keys = {
      {
        '<leader>du',
        function()
          require('dapui').toggle()
        end,
        silent = true,
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        silent = false,
      },
      {
        '<leader>dc',
        function()
          vim.opt.autochdir = true
          require('dap').continue()
          vim.opt.autochdir = false
        end,
        silent = false,
      },
      {
        '<leader>dd',
        function()
          vim.cmd.RustLsp 'debuggables'
        end,
      },
      {
        '<leader>dr',
        function()
          vim.cmd.RustLsp 'run'
        end,
      },
    },
    opts = {},
    config = function(_, opts)
      require('dapui').setup(opts)
    end,
    dependencies = {
      {
        'mfussenegger/nvim-dap',
        config = function()
          local dap = require 'dap'

          local ExecTypes = {
            TEST = 'cargo build --tests -q --message-format=json',
            BIN = 'cargo build -q --message-format=json',
          }

          local function runBuild(type)
            local lines = vim.fn.systemlist(type)
            local output = table.concat(lines, '\n')
            local filename = output:match '^.*"executable":"(.*)",.*\n.*,"success":true}$'
            if filename == nil then
              return error 'failed to build cargo project'
            end

            return filename
          end

          dap.adapters.codelldb = {
            type = 'server',
            port = '${port}',
            executable = {
              command = vim.fn.exepath 'codelldb', -- install `lldb` && use :Mason to install codelldb & cpptools
              args = { '--port', '${port}' },
            },
            name = 'codelldb',
          }

          if vim.fn.has 'win32' == 1 then
            dap.adapters.codelldb.executable.detached = false
          end

          dap.configurations.rust = {
            {
              name = 'Debug Bin',
              type = 'codelldb',
              request = 'launch',
              program = function()
                return runBuild(ExecTypes.BIN)
              end,
              cwd = '${workspaceFolder}',
              stopOnEntry = false,
              showDisassembly = 'never',
            },
            {
              name = 'Debug Test',
              type = 'codelldb',
              request = 'launch',
              program = function()
                return runBuild(ExecTypes.TEST)
              end,
              cwd = '${workspaceFolder}',
              stopOnEntry = false,
              showDisassembly = 'never',
            },
          }
        end,
      },
      'nvim-neotest/nvim-nio',
    },
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^4', -- Recommended
    lazy = false, -- This plugin is already lazy
    keys = {
      {
        '<leader>de',
        function()
          vim.cmd.RustLsp 'codeAction' -- supports rust-analyzer's grouping
          -- or vim.lsp.buf.codeAction() if you don't want grouping.
        end,
        silent = true,
      },
    },
  },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = {
      adapters = function()
        require 'rustaceanvim.neotest'
      end,
    },
  },
}
