{ pkgs, config, lib, matugen, ... }:

{
  # =========================================================================
  # Шаблоны Matugen (цвета из обоев)
  # =========================================================================
  xdg.configFile."matugen/templates/alacritty.toml".text = ''
    [window]
    opacity = 0.85
    blur = true
    padding = { x = 10, y = 10 }

    [font]
    normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
    bold   = { family = "JetBrainsMono Nerd Font", style = "Bold" }
    italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
    size = 11

    [colors.primary]
    background = "{{colors.surface.default.hex}}"
    foreground = "{{colors.on_surface.default.hex}}"

    [colors.normal]
    black   = "{{colors.surface_container_low.default.hex}}"
    red     = "{{colors.error.default.hex}}"
    green   = "{{colors.primary_container.default.hex}}"
    yellow  = "{{colors.primary_container.default.hex}}"
    blue    = "{{colors.primary.default.hex}}"
    magenta = "{{colors.primary_container.default.hex}}"
    cyan    = "{{colors.primary_container.default.hex}}"
    white   = "{{colors.on_surface.default.hex}}"
  '';

  xdg.configFile."matugen/templates/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=12
    prompt=❯
    width=50
    layer=overlay

    [colors]
    background={{colors.surface.default.hex}}cc
    text={{colors.on_surface.default.hex}}
    match={{colors.primary.default.hex}}
    selection-background={{colors.primary_container.default.hex}}
    selection-text={{colors.on_primary_container.default.hex}}
  '';

  xdg.configFile."matugen/templates/rofi.rasi".text = ''
    * {
        bg: {{colors.surface.default.hex}}e6;
        fg: {{colors.on_surface.default.hex}};
        bg-selected: {{colors.primary_container.default.hex}};
        fg-selected: {{colors.on_primary_container.default.hex}};
    }
    window {
        background-color: @bg;
        transparency: "real";
        blur-background: true;
        border-radius: 12px;
    }
    inputbar {
        children: [prompt,entry];
        background-color: transparent;
    }
    prompt {
        text-color: @fg;
    }
    entry {
        text-color: @fg;
    }
    listview {
        scrollbar: false;
    }
    element selected {
        background-color: @bg-selected;
        text-color: @fg-selected;
    }
  '';

  xdg.configFile."matugen/templates/mako.config".text = ''
    background-color={{colors.surface.default.hex}}e6
    text-color={{colors.on_surface.default.hex}}
    border-color={{colors.primary.default.hex}}
    border-size=2
    border-radius=8
    padding=15
    font=JetBrainsMono Nerd Font 10
    width=350
    max-visible=5
    default-timeout=5000
  '';

  xdg.configFile."matugen/templates/niri.toml".text = ''
    layout {
      focus-ring { off; }
      border {
        width 3
        active-color "{{colors.primary.default.hex}}"
        inactive-color "{{colors.surface_variant.default.hex}}"
        urgent-color "{{colors.error.default.hex}}"
      }
      shadow { off; }
    }
  '';

  xdg.configFile."matugen/templates/obsidian.css".text = ''
    .theme-dark {
      --background-primary: {{colors.surface.default.hex}};
      --background-primary-alt: {{colors.surface_container_low.default.hex}};
      --background-secondary: {{colors.surface_container.default.hex}};
      --background-secondary-alt: {{colors.surface_container_high.default.hex}};
      --text-normal: {{colors.on_surface.default.hex}};
      --text-accent: {{colors.primary.default.hex}};
      --interactive-accent: {{colors.primary.default.hex}};
    }
  '';

  # =========================================================================
  # Основной конфиг Matugen (пути вывода)
  # =========================================================================
  xdg.configFile."matugen/config.toml".text = ''
    [config]
    variant = "dark"
    mode = "standard"

    [config.wallpaper]
    command = "swaybg -m fill -i '{{ image }}'"
    set = true

    [templates.niri]
    input_path = "/home/krosh/.config/matugen/templates/niri.toml"
    output_path = "/home/krosh/.config/niri/colors.kdl"

    [templates.obsidian]
    input_path = "/home/krosh/.config/matugen/templates/obsidian.css"
    output_path = "/home/krosh/Document/obsidian/.obsidian/snippets/matugen.css"

    [templates.alacritty]
    input_path = "/home/krosh/.config/matugen/templates/alacritty.toml"
    output_path = "/home/krosh/.config/alacritty/alacritty.toml"

    [templates.fuzzel]
    input_path = "/home/krosh/.config/matugen/templates/fuzzel.ini"
    output_path = "/home/krosh/.config/fuzzel/fuzzel.ini"

    [templates.rofi]
    input_path = "/home/krosh/.config/matugen/templates/rofi.rasi"
    output_path = "/home/krosh/.config/rofi/theme.rasi"

    [templates.mako]
    input_path = "/home/krosh/.config/matugen/templates/mako.config"
    output_path = "/home/krosh/.config/mako/config"

    # Waybar – временно закомментирован
    # [templates.waybar]
    # input_path = "/home/krosh/.config/matugen/templates/waybar-colors.css"
    # output_path = "/home/krosh/.config/waybar/colors.css"
  '';

  # =========================================================================
  # Пакет Matugen и скрипт обновления темы
  # =========================================================================
  home.packages = with pkgs; [
    matugen.packages.${pkgs.system}.default
  ];

  home.file.".local/bin/update-theme".text = ''
    #!/bin/sh
    WALLPAPER="$1"
    if [ -z "$WALLPAPER" ]; then
      WALLPAPER=$(cat ~/.cache/current_wallpaper 2>/dev/null || echo "~/Pictures/wallpaper.jpg")
    fi
    matugen image "$WALLPAPER"
    echo "$WALLPAPER" > ~/.cache/current_wallpaper
    # pkill -SIGUSR1 waybar || waybar &   # закомментирован
  '';
  home.file.".local/bin/update-theme".executable = true;
}
