#!/bin/bash
BACKUP_DIR="/opt/rutoll/backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
CONTAINER_NAME="rutoll_lane_db"
DB_NAME="lane_transactions"
DB_USER="support_engineer"

mkdir -p "$BACKUP_DIR"

# Горячий дамп БД без остановки контейнера
docker exec -t $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME > "$BACKUP_DIR/db_backup_$DATE.sql"

if [ $? -eq 0 ]; then
    echo "[$DATE] Бэкап успешно создан: $BACKUP_DIR/db_backup_$DATE.sql"
else
    echo "[$DATE] Ошибка создания бэкапа!" >&2
    exit 1
fi

# Удаление архивов старше 7 дней
find "$BACKUP_DIR" -type f -name "*.sql" -mtime +7 -delete
