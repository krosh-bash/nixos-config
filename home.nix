{ pkgs, config, ... }:

{
  # =========================================================================
  # 1. Импорты модулей конфигурации пользователя
  # =========================================================================
  imports = [
    ./modules/niri/common.nix
  ];

  # =========================================================================
  # 2. Профильные системные параметры пользователя
  # =========================================================================
  home.username = "krosh";
  home.homeDirectory = "/home/krosh";
  home.stateVersion = "24.11";

  # =========================================================================
  # 3. Пользовательские пакеты и утилиты (home.packages)
  # =========================================================================
  home.packages = with pkgs; [
    # Базовые программы и терминал
    alacritty
    waybar
    pfetch

    # Окружение, обои и автомонтирование дисков
    udiskie
    swaybg
    mako              # сервер уведомлений (makoctl)
    fuzzel            # лаунчер меню, используемый темой
    cliphist          # менеджер буфера обмена

    # Зависимости и утилиты для скриптов панели Waybar
    pavucontrol       # управление звуком (volume-control.sh)
    bluez             # предоставляет bluetoothctl (bluetooth-control.sh)
    libnotify         # предоставляет notify-send для уведомлений
    swaylock          # экран блокировки (powermenu.sh)
  ];

  # =========================================================================
  # 4. Настройки командных оболочек (Shells)
  # =========================================================================
  programs.bash = {
    enable = true;
    initExtra = "pfetch";
  };

  # =========================================================================
  # 5. Темы оформления, курсоры и GTK внешность
  # =========================================================================
  home.pointerCursor = {
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

# =========================================================================
  # 6. Устоновка imv просмотрщиком изоброжений поумолчанию
  # =========================================================================
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "imv-dir.desktop" ];
      "image/png" = [ "imv-dir.desktop" ];
      "image/gif" = [ "imv-dir.desktop" ];
      "image/webp" = [ "imv-dir.desktop" ];
    };
  };

  # =========================================================================
  # 7. Декларативная настройка и стилизация Rofi (Catppuccin Mocha)
  # =========================================================================
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "JetBrainsMono Nerd Font 11";

    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg-col = mkLiteral "#1e1e2e";
        bg-col-light = mkLiteral "#1e1e2e";
        border-col = mkLiteral "#cba6f7";
        selected-col = mkLiteral "#313244";
        blue = mkLiteral "#89b4fa";
        fg-col = mkLiteral "#cdd6f4";
        fg-col2 = mkLiteral "#f38ba8";
        grey = mkLiteral "#6c7086";
        width = 600;
      };

      "window" = {
        height = mkLiteral "360px";
        border = mkLiteral "2px";
        border-color = mkLiteral "@border-col";
        background-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "8px";
      };

      "mainbox" = { 
        background-color = mkLiteral "@bg-col"; 
      };

      "inputbar" = {
        children = map mkLiteral [ "prompt" "entry" ];
        background-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "5px";
        padding = mkLiteral "2px";
      };

      "prompt" = {
        background-color = mkLiteral "@blue";
        padding = mkLiteral "6px";
        text-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "3px";
        margin = mkLiteral "10px 0px 0px 10px";
      };

      "entry" = {
        padding = mkLiteral "6px";
        margin = mkLiteral "10px 10px 0px 10px";
        text-color = mkLiteral "@fg-col";
        background-color = mkLiteral "#181825";
      };

      "listview" = {
        border = mkLiteral "0px";
        padding = mkLiteral "6px 0px 0px";
        margin = mkLiteral "10px 10px 0px 10px";
        columns = 1;
        lines = 8;
        background-color = mkLiteral "@bg-col";
      };

      "element" = {
        padding = mkLiteral "5px";
        background-color = mkLiteral "@bg-col";
        text-color = mkLiteral "@fg-col";
      };

      "element selected" = {
        background-color = mkLiteral "@selected-col";
        text-color = mkLiteral "@blue";
        border-radius = mkLiteral "5px";
      };
    };
  };
}

