{ pkgs, ... }: {
  stylix = {
    enable = true;
    
    # Путь к вашим обоям (Stylix сам установит их на рабочий стол)
    image = "/home/krosh/Изображения/Walpaper/11.jpg";
    
    # Алгоритм подбора цветов (генерация палитры на основе картинки)
    polarity = "dark"; # или "light" для светлой темы
#    targets.gnome.enable = false;
#    targets.gnome-text-editor.enable = false;    
    # Базовая схема (база, на которую будут накладываться цвета обоев)
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    # Настройка шрифтов (опционально, но полезно для общей гармонии)
    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font";
      };
    };
  };
}
