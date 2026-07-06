{ config, pkgs, lib, hostname, ... }:

{
  # Переопределяем выводы Niri
  programs.niri.settings.outputs = {
    "eDP-1" = {
      scale = 1.0;
      # mode = "1920x1080@60"; # если нужно
      # position = { x = 0; y = 0; };
    };
  };

  # Если на этом хосте нет тачпада (например, десктоп), можно отключить:
  # programs.niri.settings.input.touchpad.tap = false;
}
