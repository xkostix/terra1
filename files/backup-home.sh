#!/bin/bash

# Скрипт резервного копирования домашней директории

# Конфигурация
SOURCE_DIR="$HOME"
BACKUP_DIR="/tmp/backup"
RSYNC_OPTS="-av --delete --checksum --exclude=".*/""

# Начало резервного копирования
logger -t "home-backup" "Начало резервного копирования домашней директории $SOURCE_DIR в $BACKUP_DIR"

# Выполнение rsync
rsync $RSYNC_OPTS "$SOURCE_DIR/" "$BACKUP_DIR/"

# Проверка результата выполнения
RSYNC_EXIT_CODE=$?

if [ $RSYNC_EXIT_CODE -eq 0 ]; then
    logger -t "home-backup" "Резервное копирование домашней директории успешно выполнено"
    exit 0
elif [ $RSYNC_EXIT_CODE -eq 23 ] || [ $RSYNC_EXIT_CODE -eq 24 ]; then
    # Коды 23 и 24 - частичное копирование (некоторые файлы не скопированы)
    logger -t "home-backup" "Резервное копирование выполнено с предупреждениями (код: $RSYNC_EXIT_CODE)"
    exit 0
else
    logger -t "home-backup" "Ошибка резервного копирования (код: $RSYNC_EXIT_CODE)"
    exit 1
fi
