{ config, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    colorschemes.catppuccin.enable = true;

    # Базовые опции интерфейса
    plugins.lualine.enable = true;

    # Treesitter
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        ensure_installed = [
          "c" "cpp" "go" "rust" "python" "lua" "vim" "bash"
          "javascript" "typescript" "html" "css" "json" "yaml"
          "toml" "markdown" "sql" "java" "kotlin" "swift"
        ];
      };
    };

    # Инструменты навигации
    plugins.telescope = {
      enable = true;
      extensions."fzf-native".enable = true;
    };
    plugins.nvim-tree.enable = true;
    plugins.bufferline.enable = true;
    plugins.which-key.enable = true;

    # LSP
    plugins.lsp = {
      enable = true;
      servers = {
        pyright.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
          settings = {
            "rust_analyzer" = {
              checkOnSave.command = "clippy";
              cargo.allFeatures = true;
            };
          };
        };
        gopls.enable = true;
        ts_ls.enable = true;
        clangd.enable = true;
        lua_ls.enable = true;
        bashls.enable = true;
        yamlls.enable = true;
        jsonls.enable = true;
      };
    };

    # Автодополнение + сниппеты
    plugins.luasnip.enable = true;
    plugins.cmp = {
      enable = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
          { name = "luasnip"; }
        ];
        mapping = {
          # Стандартные маппинги (можно расширить)
        };
      };
    };

    # Форматирование
    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          rust = [ "rustfmt" ];
          python = [ "black" ];
          go = [ "gofmt" ];
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          typescript = [ "prettier" ];
        };
      };
    };

    # Линтинг
    plugins.lint = {
      enable = true;
      lintersByFt = {
        rust = [ "clippy" ];
        python = [ "pylint" ];
        nix = [ "nix-linter" ];
      };
    };

    # Пользовательские настройки
    extraConfigLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.mouse = 'a'
      vim.opt.termguicolors = true
      vim.g.mapleader = ' '

      -- Keymaps
      vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
      vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>')
      vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>')
      vim.keymap.set('n', '<leader>w', '<cmd>w<CR>')
    '';
  };
}
