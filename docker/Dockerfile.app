FROM ubuntu:22.04

LABEL maintainer="DevOps Lab"
LABEL description="Контейнер с демо веб-приложением"

# Установка системных зависимостей
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Создание пользователя приложения
RUN useradd -m -s /bin/bash myapp && \
    mkdir -p /opt/myapp /opt/myapp/app /opt/myapp/logs && \
    chown -R myapp:myapp /opt/myapp

# Копирование кода приложения
COPY app/ /opt/myapp/app/
COPY docker/start_app.sh /opt/myapp/start_app.sh

# Настройка прав доступа
RUN chown -R myapp:myapp /opt/myapp && \
    chmod +x /opt/myapp/start_app.sh

# Переключение на пользователя приложения
USER myapp
WORKDIR /opt/myapp

# Создание виртуального окружения и установка зависимостей
RUN python3 -m venv venv && \
    /opt/myapp/venv/bin/pip install --upgrade pip && \
    /opt/myapp/venv/bin/pip install -r app/requirements.txt

# Экспорт порта приложения
EXPOSE 8000

# Запуск приложения
CMD ["/opt/myapp/start_app.sh"]