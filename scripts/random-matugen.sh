#!/usr/bin/env bash

# Папка с обоями
WALLPAPER_DIR="$HOME/Изображения/Wallpaper"

# Случайный файл
wall=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f | shuf -n 1)

# Если файл не найден – выход с ошибкой
if [ -z "$wall" ]; then
    echo "Нет обоев в $WALLPAPER_DIR" >&2
    exit 1
fi

# Генерация цветов и установка обоев через matugen
matugen image "$wall" --source-color-index 0 --contrast 1.2

# Обновление цветов Rofi
/etc/rofi/update-colors.sh

# (опционально) перезапуск уведомлений
if command -v swaync-client &>/dev/null; then
    swaync-client -rs
fi
