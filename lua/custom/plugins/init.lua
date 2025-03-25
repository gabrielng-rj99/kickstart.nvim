-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- lua/customs/plugins/init.lua

return { -- My Plugins

  { -- Floaterm -> Popup a Terminal
    'voldikss/vim-floaterm',
    config = function()
      -- Abrir terminal flutuante no diretório do arquivo atual
      vim.cmd 'command! FloatermNewCurrentDir lua require("floaterm").new(vim.fn.expand("%:p:h"))'

      vim.g.floaterm_keymap_toggle = '<F12>' -- Atalho para abrir o terminal flutuante
      vim.g.floaterm_keymap_next = '<F8>' -- Próximo terminal
      vim.g.floaterm_keymap_prev = '<F7>' -- Terminal anterior
      vim.g.floaterm_height = 0.8
      vim.g.floaterm_width = 0.8

      vim.cmd 'map <F12> :FloatermToggle<CR>' -- Mapeia <F12> para abrir o terminal
    end,
  },

  { -- Vim Surround ()
    'tpope/vim-surround',
    -- Opcional: Você pode adicionar configurações específicas do plugin aqui
    config = function()
      -- Configurações específicas do plugin, se necessário
    end,
  },

  { -- Colorizer
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup({
        '*', -- Habilita o colorizer em todos os arquivos
      }, {
        RGB = true, -- Suporta #RGB
        RRGGBB = true, -- Suporta #RRGGBB
        names = true, -- Desativa nomes de cores (e.g. "blue")
        RRGGBBAA = true, -- Suporta #RRGGBBAA
        rgb_fn = true, -- Suporta CSS rgb() e rgba()
        hsl_fn = true, -- Suporta CSS hsl() e hsla()
      })
    end,
  },

  { -- Kanagawa ColorScheme
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('kanagawa').setup {
        undercurl = true, -- Ativa undercurl para destaque
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false, -- Não usa fundo transparente
        dimInactive = false, -- Não escurece janelas inativas
        terminalColors = true, -- Usa cores no terminal
        colors = {}, -- Deixe vazio para usar cores padrão
        background = { -- Configura o contraste de fundo
          dark = 'wave', -- Pode ser "wave" ou "dragon"
        },
        theme = 'default', -- Define o tema como padrão
        compile = false, -- Não compila o tema (opcional)
        overrides = function(colors)
          return {
            Normal = { bg = '#08080a' }, -- Define o fundo mais escuro
            -- LineNr = { fg =
            -- Comment = { fg = "#a9b1d6", italic = true },  -- Clareia os comentários
            -- NormalFloat = { fg = "#dcd7ba", bg = "#2a2a37" },  -- Clareia janelas flutuantes
          }
        end,
      }
      vim.cmd 'colorscheme kanagawa'
    end,
  },
}
