#!/bin/bash

# Скрипт запуска приложения в Docker контейнере

set -e

echo "🚀 Запуск демо веб-приложения..."

# Проверка наличия виртуального окружения
if [ ! -d "/opt/myapp/venv" ]; then
    echo "❌ Виртуальное окружение не найдено. Создаю..."
    python3 -m venv /opt/myapp/venv
fi

# Активация виртуального окружения
echo "🔧 Активация виртуального окружения..."
source /opt/myapp/venv/bin/activate

# Установка зависимостей
if [ ! -f "/opt/myapp/venv/installed" ]; then
    echo "📦 Установка зависимостей Python..."
    cd /opt/myapp/app
    pip install --upgrade pip
    pip install -r requirements.txt
    touch /opt/myapp/venv/installed
fi

# Переход в директорию приложения
cd /opt/myapp/app

# Проверка конфигурации
echo "🔍 Проверка конфигурации..."
if [ -f ".env" ]; then
    echo "✅ Конфигурационный файл найден"
    source .env
else
    echo "⚠️ Конфигурационный файл не найден, использую переменные окружения"
fi

# Создание необходимых директорий
echo "📁 Создание директорий..."
mkdir -p /opt/myapp/logs
mkdir -p /tmp

# Настройка логирования
export PYTHONPATH=/opt/myapp/app:$PYTHONPATH

# Запуск приложения
echo "🎯 Запуск приложения..."
echo "   Хост: $APP_HOST"
echo "   Порт: $APP_PORT"
echo "   Режим отладки: $DEBUG"

# Использование gunicorn для продакшена
if [ "$DEBUG" = "false" ]; then
    echo "🏭 Запуск в продакшен режиме с gunicorn..."
    exec gunicorn \
        --bind $APP_HOST:$APP_PORT \
        --workers 4 \
        --worker-class sync \
        --log-level info \
        --access-logfile /opt/myapp/logs/access.log \
        --error-logfile /opt/myapp/logs/error.log \
        --capture-output \
        --enable-redirect-access \
        app:app
else
    echo "🐛 Запуск в режиме разработки..."
    exec python3 app.py
fi