#!/bin/bash

# Скрипт для мониторинга системы
# Собирает информацию о CPU, памяти, диске и сохраняет в БД

DB_HOST=${DB_HOST:-db}
DB_USER=${DB_USER:-postgres}
DB_PASS=${DB_PASS:-password}
DB_NAME=${DB_NAME:-monitor_db}

echo "=== Системный монитор ==="
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# CPU использование
CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/")
CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc)
echo "CPU использование: ${CPU_USAGE}%"

# Память
MEM_INFO=$(free | grep Mem)
MEM_TOTAL=$(echo $MEM_INFO | awk '{print $2}')
MEM_USED=$(echo $MEM_INFO | awk '{print $3}')
echo "Память: Использовано ${MEM_USED} KB из ${MEM_TOTAL} KB"

# Диск
DISK_INFO=$(df / | tail -1)
DISK_TOTAL=$(echo $DISK_INFO | awk '{print $2}')
DISK_USED=$(echo $DISK_INFO | awk '{print $3}')
echo "Диск: Использовано ${DISK_USED} KB из ${DISK_TOTAL} KB"

# Сохраняем в БД
PGPASSWORD=$DB_PASS psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "
CREATE TABLE IF NOT EXISTS system_metrics (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP,
    cpu_usage FLOAT,
    mem_used BIGINT,
    mem_total BIGINT,
    disk_used BIGINT,
    disk_total BIGINT
);
INSERT INTO system_metrics (timestamp, cpu_usage, mem_used, mem_total, disk_used, disk_total)
VALUES ('$TIMESTAMP', $CPU_USAGE, $MEM_USED, $MEM_TOTAL, $DISK_USED, $DISK_TOTAL);
"

echo "Данные сохранены в БД"
echo "=== Конец отчета ==="