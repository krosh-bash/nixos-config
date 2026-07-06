{ config, pkgs, ... }:

{
  # Язык системы
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Раскладка клавиатуры (переключение по Caps Lock)
  services.xserver.xkb = {
    layout = "us,ru";
    variant = " ,";
    options = "grp:caps_toggle";
  };

  # Применять настройки клавиатуры в консоли (TTY)
  console.useXkbConfig = true;
}
