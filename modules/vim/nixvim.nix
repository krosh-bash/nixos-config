{ config, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    colorschemes.catppuccin.enable = true;

    # Treesitter — быстрая подсветка
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

    # LSP-серверы (устанавливаются через nixpkgs)
    plugins.lsp = {
      enable = true;
      servers = {
        pyright.enable = true;          # Python
        rust-analyzer.enable = true;    # Rust
        gopls.enable = true;            # Go
        ts_ls.enable = true;            # TypeScript/JavaScript
        clangd.enable = true;           # C/C++
        lua_ls.enable = true;           # Lua
        bashls.enable = true;           # Bash
        yamlls.enable = true;           # YAML
        jsonls.enable = true;           # JSON
      };
    };

    # Автодополнение (nvim-cmp) — правильное имя плагина: cmp
    plugins.cmp = {
      enable = true;
      # Автоматически подключаем стандартные источники
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        # Дополнительно можно настроить поведение, но базовое уже работает
      };
    };
  };
}
