# Базовый легковесный образ Linux Alpine
FROM alpine:3.18

# Установка системных утилит, необходимых инженеру техподдержки для диагностики
RUN apk update && apk add --no-cache \
    bash \
    curl \
    postgresql-client \
    tzdata

# Настройка временной зоны (Москва/Санкт-Петербург) для корректности таймстампов в логах
ENV TZ=Europe/Moscow

# Создание рабочей директории для скриптов системы взимания платы
WORKDIR /opt/rutoll/lane

# Создание точки монтирования для лог-файлов оборудования полосы
RUN mkdir -p /var/log

# Копируем или создаем базовый скрипт эмуляции сигналов оборудования прямо внутри образа
RUN echo -e '#!/bin/bash\n\
echo "RUTOLL Lane Emulator Service Started"\n\
while true; do\n\
  echo "$(date +\"%Y-%m-%d %H:%M:%S\") [INFO] Vehicle class detected: 2" >> /var/log/driveway.log;\n\
  sleep 3;\n\
  echo "$(date +\"%Y-%m-%d %H:%M:%S\") [INFO] Command sent: OPEN_BARRIER" >> /var/log/driveway.log;\n\
  sleep 1;\n\
  echo "$(date +\"%Y-%m-%d %H:%M:%S\") [INFO] Barrier event: SUCCESSFULLY_OPENED" >> /var/log/driveway.log;\n\
  sleep 5;\n\
done' > ./start_emulator.sh

# Предоставление прав на исполнение скрипта эмулятора
RUN chmod +x ./start_emulator.sh

# Инструкция для запуска циклического логирования при старте контейнера
CMD ["./start_emulator.sh"]