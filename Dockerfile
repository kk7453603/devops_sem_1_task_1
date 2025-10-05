# Используем Ubuntu как базовый образ
FROM ubuntu:20.04

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y \
    procps \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Копируем скрипт в контейнер
COPY system_monitor.sh /usr/local/bin/system_monitor.sh

# Делаем скрипт исполняемым
RUN chmod +x /usr/local/bin/system_monitor.sh

# Запускаем скрипт
CMD ["/usr/local/bin/system_monitor.sh"]