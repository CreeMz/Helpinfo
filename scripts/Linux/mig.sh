#!/bin/bash
# backup_interactive_menu.sh

# Функция для отображения меню
show_menu() {
    clear
    echo "========================================"
    echo "         МАСТЕР СОЗДАНИЯ БЭКАПА"
    echo "========================================"
    echo ""
    
    # Показать текущие диски
    echo "Текущие диски в системе:"
    echo "----------------------------------------"
    lsblk -d -n -o NAME,SIZE,MODEL | while read -r LINE; do
        DISK=$(echo "$LINE" | awk '{print $1}')
        SIZE=$(echo "$LINE" | awk '{print $2}')
        MODEL=$(echo "$LINE" | cut -d' ' -f3-)
        printf "%-10s %-10s %s\n" "/dev/$DISK" "$SIZE" "$MODEL"
    done
    echo "----------------------------------------"
    echo ""
}

# Функция выбора диска
select_disk() {
    show_menu
    
    echo "1. Бэкап системного диска"
    echo "2. Бэкап всех дисков"
    echo "3. Выбрать диск вручную"
    echo "4. Показать детали дисков"
    echo "0. Выход"
    echo ""
    
    read -p "Выберите действие: " MAIN_CHOICE
    
    case $MAIN_CHOICE in
        1)
            # Системный диск
            DISK=$(lsblk -no pkname $(findmnt -n -o SOURCE /) 2>/dev/null || echo "sda")
            echo "Выбран системный диск: /dev/$DISK"
            return 0
            ;;
        2)
            # Все диски
            DISKS=$(lsblk -d -n -o NAME | grep -v loop | tr '\n' ' ')
            echo "Выбраны все диски: $DISKS"
            MULTI_DISK=true
            return 0
            ;;
        3)
            # Ручной выбор
            show_menu
            echo ""
            read -p "Введите имя диска (например: sda, nvme0n1): " DISK
            if [ ! -b "/dev/$DISK" ]; then
                echo "Диск /dev/$DISK не найден"
                return 1
            fi
            return 0
            ;;
        4)
            # Детали
            clear
            lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL
            echo ""
            read -p "Нажмите Enter для продолжения..."
            select_disk
            ;;
        0)
            exit 0
            ;;
        *)
            echo "Неверный выбор"
            sleep 2
            select_disk
            ;;
    esac
}

# Функция параметров шары
get_share_params() {
    echo ""
    echo "--- ПАРАМЕТРЫ СЕТЕВОЙ ШАРЫ ---"
    echo ""
    
    read -p "SMB share (//server/share): " SHARE
    [[ -z "$SHARE" ]] && { echo "Путь обязателен"; return 1; }
    
    read -p "Mount point [/mnt/backup]: " MOUNT
    MOUNT=${MOUNT:-/mnt/backup}
    
    read -p "Username: " USER
    [[ -z "$USER" ]] && { echo "Имя пользователя обязательно"; return 1; }
    
    read -sp "Password: " PASS
    echo ""
    [[ -z "$PASS" ]] && { echo "Пароль обязателен"; return 1; }
    
    read -p "Domain [WORKGROUP]: " DOMAIN
    DOMAIN=${DOMAIN:-WORKGROUP}
    
    return 0
}

# Функция бэкапа
perform_backup() {
    local DISK=$1
    
    echo ""
    echo "=== Бэкап диска /dev/$DISK ==="
    
    # Монтирование
    echo "Монтирую шару..."
    sudo mkdir -p "$MOUNT"
    if ! sudo mount -t cifs "$SHARE" "$MOUNT" \
        -o "username=$USER,password=$PASS,domain=$DOMAIN,vers=3.0"; then
        echo "Ошибка монтирования"
        return 1
    fi
    
    # Заморозка
    echo "Замораживаю файловые системы..."
    MOUNTED_PARTS=$(findmnt -l -n -o TARGET -S "/dev/$DISK" 2>/dev/null || true)
    for PART in $MOUNTED_PARTS; do
        sudo fsfreeze -f "$PART" 2>/dev/null || true
    done
    
    # Бэкап
    BACKUP_FILE="${MOUNT}/backup_${DISK}_$(date +%Y%m%d_%H%M%S).raw"
    echo "Создаю: $(basename $BACKUP_FILE)"
    
    START=$(date +%s)
    sudo dd if="/dev/$DISK" \
        of="$BACKUP_FILE" \
        bs=4M \
        conv=sparse,noerror,sync \
        status=progress
    END=$(date +%s)
    
    # Разморозка
    for PART in $MOUNTED_PARTS; do
        sudo fsfreeze -u "$PART" 2>/dev/null || true
    done
    
    # Размонтирование
    sudo umount "$MOUNT"
    
    # Результат
    if [ -f "$BACKUP_FILE" ]; then
        SIZE=$(stat -c%s "$BACKUP_FILE" 2>/dev/null || echo "0")
        echo "✓ Завершено за $((END-START)) сек"
        echo "  Размер: $((SIZE/1024/1024/1024)) GB"
        return 0
    else
        echo "✗ Ошибка создания файла"
        return 1
    fi
}

# Главная функция
main() {
    # Выбор диска
    if ! select_disk; then
        exit 1
    fi
    
    # Параметры шары
    if ! get_share_params; then
        exit 1
    fi
    
    # Подтверждение
    echo ""
    echo "=== ПОДТВЕРЖДЕНИЕ ==="
    if [ "$MULTI_DISK" = true ]; then
        echo "Диски: $DISKS"
    else
        echo "Диск: /dev/$DISK"
    fi
    echo "Шара: $SHARE"
    echo "Пользователь: $USER"
    echo ""
    
    read -p "Начать бэкап? (y/N): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
    
    # Выполнение бэкапа
    if [ "$MULTI_DISK" = true ]; then
        for SINGLE_DISK in $DISKS; do
            if ! perform_backup "$SINGLE_DISK"; then
                echo "Ошибка при бэкапе диска $SINGLE_DISK"
            fi
            echo ""
        done
    else
        perform_backup "$DISK"
    fi
    
    echo ""
    echo "=== ГОТОВО ==="
}

# Запуск
main
