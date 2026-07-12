#!/usr/bin/env bash

# Папка с обоями
WALL_DIR="$HOME/Изображения/Walpaper"

# Путь к файлу обоев, который использует stylix (должен совпадать с указанным в home.nix)
WALLPAPER_DEST="/etc/nixos/wallpaper.jpg"

# 1. Выбираем случайный файл
WALL=$(find "$WALL_DIR" -maxdepth 1 -type f | shuf -n 1)
if [ -z "$WALL" ]; then
    echo "Ошибка: нет файлов в $WALL_DIR"
    exit 1
fi
echo "Выбраны обои: $WALL"

# 2. Копируем файл в папку с конфигурацией NixOS
sudo cp "$WALL" "$WALLPAPER_DEST"

# 3. Меняем обои в текущей сессии (через swaybg)
killall swaybg 2>/dev/null
swaybg -m fill -i "$WALL" &

# 4. Пересобираем систему, чтобы stylix перегенерировал тему
sudo nixos-rebuild switch --flake .#krosh

# 5. Перезапускаем приложения, чтобы они подхватили новые цвета
killall -SIGUSR2 waybar 2>/dev/null   # если waybar поддерживает перезагрузку
pkill -USR1 mako 2>/dev/null          # обновление mako
# Для niri можно отправить сигнал перезагрузки конфига, если это поддерживается
# (например, pkill -SIGUSR1 niri) — проверьте документацию niri
