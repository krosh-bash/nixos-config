{ pkgs, ... }:

{
  # Создаем символическую ссылку на ваш config.kdl
  xdg.configFile."niri/config.kdl" = {
    source = ./config.kdl;
    force = true;
  };

  # Так как модуля niri в HM нет, автозапуск waybar лучше прописать прямо 
  # в ваш физический файл config.kdl.
  # Для этого откройте ваш файл ./modules/niri/config.kdl и добавьте туда строки:
  # spawn-at-startup "waybar"
}

