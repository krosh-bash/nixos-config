{ pkgs, config, lib, ... }:

let
  c = config.lib.stylix.colors;
  terminalFont = config.stylix.fonts.monospace;
  terminalFontSize = config.stylix.fonts.sizes.terminal;
  terminalOpacity = config.stylix.opacity.terminal;
in
{
  imports = [ ./modules/niri/common.nix ];

  home.username = "krosh";
  home.homeDirectory = "/home/krosh";
  home.stateVersion = "24.11";

  stylix = {
    enable = true;
    image = ./wallpaper.jpg;
    polarity = "dark";
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sizes = {
        terminal = 11;
        popups = 11;
      };
    };
    opacity = {
      terminal = 0.75;
    };
    targets = {
      gtk.enable = true;
      mako.enable = true;
      rofi.enable = true;
#      niri.enable = true;   
    };
  };

  home.packages = with pkgs; [
    alacritty
    waybar
    pfetch
    udiskie
    mako
    fuzzel
    cliphist
    pavucontrol
    bluez
    libnotify
    swaylock
    swaybg           # <-- добавляем
  ];

  programs.bash = {
    enable = true;
    initExtra = "pfetch";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        blur = true;
        dimensions = {
          columns = 100;
          lines = 25;
        };
        opacity = terminalOpacity;
      };
      colors = lib.mkForce {
        primary = {
          background = "#${c.base00}";
          foreground = "#${c.base05}";
        };
        cursor = {
          text = "#${c.base00}";
          cursor = "#${c.base05}";
        };
        normal = {
          black   = "#${c.base00}";
          red     = "#${c.base08}";
          green   = "#${c.base0B}";
          yellow  = "#${c.base0A}";
          blue    = "#${c.base0D}";
          magenta = "#${c.base0E}";
          cyan    = "#${c.base0C}";
          white   = "#${c.base05}";
        };
        bright = {
          black   = "#${c.base03}";
          red     = "#${c.base08}";
          green   = "#${c.base0B}";
          yellow  = "#${c.base0A}";
          blue    = "#${c.base0D}";
          magenta = "#${c.base0E}";
          cyan    = "#${c.base0C}";
          white   = "#${c.base07}";
        };
        indexed_colors = [
          { index = 16; color = "#${c.base09}"; }
          { index = 17; color = "#${c.base0F}"; }
        ];
      };
      font = {
        normal = {
          family = terminalFont.name;
          style = "Regular";
        };
        bold = {
          family = terminalFont.name;
          style = "Bold";
        };
        italic = {
          family = terminalFont.name;
          style = "Italic";
        };
        size = terminalFontSize;
      };
    };
  };

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
