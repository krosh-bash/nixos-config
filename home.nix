{ pkgs, config, lib, ... }:

{
  imports = [
    ./modules/mpv/mpv.nix
     ./modules/home/macchina.nix
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
  home.file."$HOME/.config/rmpc".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/rmpc";

  # =========================================================================
  # 3. Пакеты пользователя (без matugen – он уже в модуле)
  # =========================================================================
  home.packages = with pkgs; [
    macchina
    fuzzel
    rofi
    mako
    alacritty
    niri
    obsidian
  ];

services.kdeconnect = {
  enable = true;
  indicator = true; # Включает иконку в системном трее
};

xdg.desktopEntries."pinecone-mc" = {
    name = "PineconeMC";
    genericName = "Minecraft launcher";
    exec = "${pkgs.appimage-run}/bin/appimage-run /home/krosh/utilits/PineconeMC-Linux-x86_64.AppImage";
    icon = "/home/krosh/Изображения/Icon/PineconeMc.png";
    terminal = false;
    categories = [ "Game" ];
  };
xdg.desktopEntries."xmcl" = {
    name = "XMCL";
    genericName = "Minecraft launcher";
    exec = "${pkgs.appimage-run}/bin/appimage-run /home/krosh/utilits/xmcl-0.67.0-x86_64.AppImage --no-sandbox --disable-gpu-sandbox";
    icon = "/home/krosh/Изображения/Icon/xmcl_logo.png";
    terminal = false;
    categories = [ "Game" ];
  };

targets.genericLinux = {
    enable = true;
    nixGL.installScripts = ["mesa"];   # для Intel, AMD и встроек
  };

programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin 
    then pkgs.ghostty-bin 
    else config.lib.nixGL.wrap pkgs.ghostty;
     
    # Enable for whichever shell you plan to use!
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    settings = {
      theme = "GitHub Dark High Contrast";
      background-opacity = "0.95";
    };
  };
  # =========================================================================
  # 4. Настройки zsh
  # =========================================================================
  programs.zsh = {
    enable = true;
    history.size = 10000;

    shellAliases = {
      # Заменяем стандартный ls на lsd
     ls = "lsd";
     l  = "lsd -l";
     ll = "lsd -l";
     la = "lsd -a";
     lla = "lsd -la";
     lt = "lsd --tree";

      nhh = "nh home switch .";
      nhs = "nh os switch .";
      nhus = "nh os switch -u .";
    };

    initContent = ''
      macchina
      eval "$(zoxide init zsh --cmd cd)"
      __zoxide_zi() {
        local dir
        dir="$(zoxide query -l | fzf --height 40% --layout=reverse --info=inline --prompt="⚡ Перейти в папку: ")" && cd "$dir"
        zle reset-prompt
      }
      zle -N __zoxide_zi
      bindkey '^G' __zoxide_zi
    '';

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "dirhistory" "kubectl" ];
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
