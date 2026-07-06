{ config, pkgs, ... }:

{
  # Устанавливаем шрифты
  fonts.packages = with pkgs; [
       
    # Современные качественные шрифты с поддержкой башкирского:
    jetbrains-mono
    fira-code
    inter
    # Базовые латиница + кириллица
    dejavu_fonts
    liberation_ttf
    noto-fonts

    # Китайские иероглифы (упрощённые и традиционные)
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    # Эмодзи
    noto-fonts-color-emoji

    # Шрифты с иконками для терминала (Nerd Fonts)
    # Выберите один или несколько:
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only  # только иконки (можно миксовать)
  ];

  # Настройка fontconfig (для корректного выбора шрифтов)
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["JetBrainsMono Nerd Font" "Hack Nerd Font" "DejaVu Sans Mono" "Noto Sans Mono" ];
      sansSerif = ["Inter" "Noto Sans" "DejaVu Sans" ];
      serif = [ "Noto Serif" "DejaVu Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
