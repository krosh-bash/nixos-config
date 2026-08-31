# Файл: mpv.nix (для Home Manager)
{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    # Nix сам найдет плагин mpris в актуальном store и подключит его
    scripts = [ pkgs.mpvScripts.mpris ]; 
    
    config = {
      # Специфичные настройки для музыки
      directory-filter-types = "video,audio,archive,playlist";
      audio-display = "no"; # Игнорировать обложки альбомов типа cover.jpg

      # Аппаратное декодирование и видео
      hwdec = "auto-safe";
      vo = "gpu";
      gpu-context = "wayland";
      profile = "gpu-hq";
      deband = "yes";
      cscale = "lanczos";
      scale = "lanczos"; # Опечатка laczos исправлена

      # Плавность движения
      video-sync = "display-resample";
      interpolation = "yes";
      tscale = "linear";

      # Интерфейс
      no-border = ""; # Пустая строка активирует флаги без аргументов
      cursor-autohide = "1000";
      save-position-on-quit = "yes";

      # Субтитры и Аудио
      slang = "rus,eng,ru";
      alang = "rus,eng,ru";
      sub-auto = "fuzzy";
      sub-font = "sans-serif";
      sub-font-size = "40";

      # Скриншоты
      screenshot-format = "png";
      screenshot-high-bit-depth = "yes";
      screenshot-directory = "~/Pictures/mpv_screenshots";

      # Управление цветом
      video-output-levels = "full";
      target-colorspace-hint = "no";

      # Кэш и YouTube
      ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
      cache = "yes";
      demuxer-max-bytes = "300MiB";
      demuxer-max-back-bytes = "100MiB";
      cache-pause-initial = "yes";
    };
  };
}

