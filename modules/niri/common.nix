{ config, pkgs, lib, ... }:

let
  c = config.lib.stylix.colors;   # цвета, извлечённые из обоев
in
{
  # Генерируем полный конфиг с подстановкой цветов
  xdg.configFile."niri/config.kdl" = {
    text = ''
      // Input device configuration.
      input {
        keyboard {
          xkb {
            layout "us,ru"
            variant ",bak"
            options "grp:caps_toggle"
          }
          // Enables numlock on startup
          // numlock
        }

        touchpad {
          tap
          accel-speed 0.1
          accel-profile "adaptive"
        }

        mouse {
          // off
          // natural-scroll
          // accel-speed 0.2
          // accel-profile "flat"
          // scroll-method "no-scroll"
        }

        trackpoint {
          // off
          // natural-scroll
          // accel-speed 0.2
          // accel-profile "flat"
          // scroll-method "on-button-down"
          // scroll-button 273
          // scroll-button-lock
          // middle-emulation
        }

        // warp-mouse-to-focus
        focus-follows-mouse max-scroll-amount="0%"
      }

      layout {
        gaps 3
        center-focused-column "never"

        preset-column-widths {
          proportion 0.5
          proportion 0.66
          proportion 0.33
        }

        preset-window-heights {
          proportion 0.5
          proportion 1.0
        }

        default-column-width { proportion 0.5; }

        focus-ring {
          off
          width 5
          inactive-color "#${c.base03}"
          active-gradient from="#${c.base0D}" to="#${c.base0A}" angle=135
        }

        border {
          // off
          width 5
          inactive-color "#${c.base03}"
          active-gradient from="#${c.base08}" to="#${c.base0B}" angle=135
          urgent-color "#${c.base08}"
        }

        shadow {
          off
        }
      }

      spawn-at-startup "gnome-keyring"
      spawn-at-startup "hypridle"
      spawn-at-startup "xwayland-satellite"
      spawn-at-startup "wl-paste" "--type" "text" "--watch" "cliphist" "store"
      spawn-at-startup "wl-paste" "--type" "image" "--watch" "cliphist" "store"
      spawn-at-startup "waybar"
      spawn-at-startup "/etc/nixos/scripts/random-swaybg"
      spawn-at-startup "swaync"
      spawn-at-startup "udiskie" "-n"

      hotkey-overlay {
        // skip-at-startup
      }

      prefer-no-csd
      screenshot-path "~/screens/Screenshot from %Y-%m-%d %H-%M-%S.png"

      animations {
        // off
        // slowdown 3.0

        workspace-switch {
          spring damping-ratio=0.8 stiffness=1000 epsilon=0.0001
        }

        window-open {
          duration-ms 150
          curve "ease-out-quad"
        }

        window-close {
          duration-ms 150
          curve "ease-out-quad"
        }

        horizontal-view-movement {
          spring damping-ratio=0.8 stiffness=800 epsilon=0.0001
        }

        window-movement {
          spring damping-ratio=0.8 stiffness=800 epsilon=0.0001
        }

        window-resize {
          spring damping-ratio=0.8 stiffness=800 epsilon=0.0001
        }

        config-notification-open-close {
          spring damping-ratio=0.6 stiffness=1000 epsilon=0.001
        }

        exit-confirmation-open-close {
          spring damping-ratio=0.6 stiffness=500 epsilon=0.01
        }

        screenshot-ui-open {
          duration-ms 200
          curve "ease-out-quad"
        }

        overview-open-close {
          spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
        }

        recent-windows-close {
          spring damping-ratio=1.0 stiffness=800 epsilon=0.001
        }
      }

      workspace "1"
      workspace "2"
      workspace "3"
      workspace "4"
      workspace "5"
      workspace "6"
      workspace "7"
      workspace "8"

      window-rule {
        match app-id="obsidian"
        open-on-workspace "3"
      }

      window-rule {
        match app-id="org.telegram.desktop"
        open-on-workspace "5"
      }

      window-rule {
        match app-id="vesktop"
        open-on-workspace "5"
      }

      window-rule {
        match app-id="showmethekey-gtk"
        open-floating true
        open-focused false
        default-floating-position x=990 y=28 relative-to="top-left"
        min-width 900
        min-height 170

        border {
          off
        }
      }

      window-rule {
        opacity 0.8
      }

      window-rule {
        match app-id="^(mpv|imv|anki|showmethekey-gtk|Emulator|Android Emulator|blueman-manager)$"
        open-floating true
      }

      window-rule {
        match app-id=r#"^org\.wezfurlong\.wezterm$"#
        default-column-width {}
      }

      window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        open-floating true
      }

      // Пример правила с блокировкой – оставлен закомментированным, как у вас
      /-window-rule {
        match app-id=r#"^org\.keepassxc\.KeePassXC$"#
        match app-id=r#"^org\.gnome\.World\.Secrets$"#
        block-out-from "screen-capture"
      }

      // Пример скругления углов – закомментирован
      /-window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
      }

      binds {
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+Q { spawn "alacritty" "-e" "yazi"; }
        Mod+B { spawn "zen-browser"; }
        Mod+Shift+Return hotkey-overlay-title="Open a Terminal: alacritty" { spawn "alacritty"; }
        Mod+D { spawn "rofi" "-show" "drun"; }
        Mod+N hotkey-overlay-title="Notification center" { spawn-sh "swaync-client -t"; }
        Mod+Z { spawn "/etc/nixos/scripts/rofi-clipboard"; }
        Mod+Shift+Escape { spawn "/etc/nixos/scripts/rofi-power"; }
        Mod+Shift+S { spawn "udiskie-umount" "-a"; }
        Mod+A { spawn "/etc/nixos/scripts/random-swaybg"; }
        Mod+Shift+B { spawn "/etc/nixos/scripts/rofi-bluetooth"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-"; }
        XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

        XF86AudioPlay        allow-when-locked=true { spawn-sh "playerctl play-pause"; }
        XF86AudioStop        allow-when-locked=true { spawn-sh "playerctl stop"; }
        XF86AudioPrev        allow-when-locked=true { spawn-sh "playerctl previous"; }
        XF86AudioNext        allow-when-locked=true { spawn-sh "playerctl next"; }

        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+5%"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "5%-"; }

        Mod+O repeat=false { toggle-overview; }
        Mod+Shift+C repeat=false { close-window; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Right { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }
        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End  { move-column-to-last; }

        Mod+Ctrl+Left  { focus-monitor-left; }
        Mod+Ctrl+Down  { focus-monitor-down; }
        Mod+Ctrl+Up    { focus-monitor-up; }
        Mod+Ctrl+Right { focus-monitor-right; }

        Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
        Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

        Mod+Shift+Page_Down { move-workspace-down; }
        Mod+Shift+Page_Up   { move-workspace-up; }
        Mod+Shift+U         { move-workspace-down; }
        Mod+Shift+I         { move-workspace-up; }

        Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

        Mod+WheelScrollRight      { focus-column-right; }
        Mod+WheelScrollLeft       { focus-column-left; }
        Mod+Ctrl+WheelScrollRight { move-column-right; }
        Mod+Ctrl+WheelScrollLeft  { move-column-left; }

        Mod+Shift+WheelScrollDown      { focus-column-right; }
        Mod+Shift+WheelScrollUp        { focus-column-left; }
        Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
        Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        Mod+BracketLeft  { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }
        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+M { maximize-window-to-edges; }

        Mod+Ctrl+F { expand-column-to-available-width; }
        Mod+C { center-column; }
        Mod+Ctrl+C { center-visible-columns; }

        Mod+Minus { set-column-width "-5%"; }
        Mod+Equal { set-column-width "+5%"; }
        Mod+Shift+Minus { set-window-height "-5%"; }
        Mod+Shift+Equal { set-window-height "+5%"; }

        Mod+V       { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        Mod+W { toggle-column-tabbed-display; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
        Mod+Shift+E { quit; }
        Mod+Shift+P { power-off-monitors; }
      }

      output "eDP-1" {
        scale 1.0
      }
    '';
    force = true;
  };
}
