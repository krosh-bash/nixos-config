#!/bin/bash
# Ищем первое устройство типа 'partition'
DEVICE=$(lsblk -o NAME,TYPE -n | grep 'part' | head -n1 | awk '{print "/dev/"$1}')
if [ -z "$DEVICE" ]; then
    echo "Не найдено ни одного раздела."
    exit 1
fi
echo "Монтирую $DEVICE в ~/usb"
sudo mount $DEVICE ~/usb
