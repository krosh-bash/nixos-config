{ pkgs, config, lib, ... }:

{
  imports = [
    ./modules/matugen.nix   # подключаем модуль Matugen
  ];

  home.username = "krosh";
  home.homeDirectory = "/home/krosh";
  home.stateVersion = "26.05";

  # =========================================================================
  # 1. Глобальные настройки dconf (темный режим)
  # =========================================================================
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # =========================================================================
  # 2. Симлинки для rmpc (не относятся к Matugen)
  # =========================================================================
home.file.".config/rmpc".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/rmpc";
  # =========================================================================
  # 3. Пакеты пользователя (без matugen – он уже в модуле)
  # =========================================================================
  home.packages = with pkgs; [
    fuzzel
    rofi
    mako
    alacritty
    niri
    obsidian
    pfetch
    rmpc
    # waybar – закомментирован
  ];

  # =========================================================================
  # 4. Настройки zsh
  # =========================================================================
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "kubectl" ];
    };
  };

  # =========================================================================
  # 5. Остальное (GTK, курсор, переменные, ассоциации)
  # =========================================================================
  home.pointerCursor = {
    enable = true;
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "phinger-cursors-light";
      size = 24;
      package = pkgs.phinger-cursors;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "imv-dir.desktop" ];
      "image/png"  = [ "imv-dir.desktop" ];
      "image/gif"  = [ "imv-dir.desktop" ];
      "image/webp" = [ "imv-dir.desktop" ];
    };
  };
}
