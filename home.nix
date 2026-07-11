{ pkgs, config, lib, ... }:

let
  c = config.lib.stylix.colors;   # для цветов в Rofi
in
{
  imports = [ ];   # пустой, все модули подключаются из flake.nix

  home.username = "krosh";
  home.homeDirectory = "/home/krosh";
  home.stateVersion = "24.11";

  stylix = {
    enable = true;
    image = ./wallpaper.jpg;   # <--- вот конкретный файл
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
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
      alacritty.enable = true;
      gtk.enable = true;
      mako.enable = true;
      gnome-text-editor.enable = false;
      gnome.enable = false;
      rofi.enable = true; 
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
      };
      colors = {
        draw_bold_text_with_bright_colors = true;
      };
    };
  };

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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "imv-dir.desktop" ];
      "image/png" = [ "imv-dir.desktop" ];
      "image/gif" = [ "imv-dir.desktop" ];
      "image/webp" = [ "imv-dir.desktop" ];
    };
  };



  xdg.configFile."niri/config.kdl" = {
    source = ./modules/niri/config.kdl;
    force = true;
  };
}
