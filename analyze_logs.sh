#!/bin/bash

# ==============================================================================
# Скрипт технического анализа логов оборудования полосы для ООО "Рутолл"
# ==============================================================================

LOG_FILE="./log_data/driveway.log"
REPORT_FILE="./log_data/incident_report_$(date +%Y-%m-%d).txt"

echo "=== ИНИЦИАЛИЗАЦИЯ АНАЛИЗА ЖУРНАЛОВ ПОВРЕЖДЕНИЙ ПОЛОСЫ ==="
echo "Отчет сформирован: $(date)" > "$REPORT_FILE"
echo "--------------------------------------------------" >> "$REPORT_FILE"

# 1. Проверка наличия лог-файла
if [ ! -f "$LOG_FILE" ]; then
    # Если запуск локальный, пробуем забрать лог напрямую из работающего контейнера
    echo "[WARN] Локальный файл логов не найден. Попытка выгрузки из контейнера lane_emulator..."
    docker cp lane_emulator:/var/log/driveway.log "$LOG_FILE" 2>/dev/null
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "[ERROR] Критическая ошибка: Файл driveway.log недоступен для анализа!"
    exit 1
fi

# 2. Подсчет общей статистики проездов (Класс 2 - легковые/коммерческие)
TOTAL_VEHICLES=$(grep -c "Vehicle class detected: 2" "$LOG_FILE")
echo "Всего зафиксировано транспортных средств класса 2: $TOTAL_VEHICLES" >> "$REPORT_FILE"

# 3. Поиск потенциальных инцидентов и ошибок
echo "=== ПОИСК КРИТИЧЕСКИХ СБОЕВ И ОШИБОК ОБОРУДОВАНИЯ ===" >> "$REPORT_FILE"
grep -E "ERROR|CRITICAL|TIMEOUT|FAIL" "$LOG_FILE" >> "$REPORT_FILE"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Критических аппаратных ошибок в цикле работы шлагбаума не обнаружено." >> "$REPORT_FILE"
fi

# 4. Выгрузка таймингов работы барьера (анализ задержек открытия)
echo "" >> "$REPORT_FILE"
echo "=== СТАТИСТИКА СРАБАТЫВАНИЯ ШЛАГБАУМА (ПОСЛЕДНИЕ 5 ОПЕРАЦИЙ) ===" >> "$REPORT_FILE"
grep -E "COMMAND_SENT|SUCCESSFULLY_OPENED" "$LOG_FILE" | tail -n 10 >> "$REPORT_FILE"

echo "--------------------------------------------------" >> "$REPORT_FILE"
echo "[INFO] Анализ завершен. Результаты сохранены в: $REPORT_FILE"
cat "$REPORT_FILE"
