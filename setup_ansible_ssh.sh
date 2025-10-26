#!/bin/bash

# Скрипт настройки SSH ключей для работы Ansible с чистыми контейнерами

set -e

echo "🔑 Настройка SSH ключей для Ansible..."
echo "========================================"

# Проверка запущенных контейнеров
echo "1. Проверка контейнеров..."
docker-compose ps

# Подключение к ansible-master и настройка SSH ключей
echo ""
echo "2. Настройка SSH ключей в ansible-master..."

# Генерация SSH ключей если их нет
echo "Генерация SSH ключей..."
docker-compose exec -T ansible-master bash -c '
    if [ ! -f /root/.ssh/id_rsa ]; then
        echo "Создание новых SSH ключей..."
        ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N "" -q
    else
        echo "SSH ключи уже существуют"
    fi
'

# Копирование публичного ключа в целевые контейнеры
echo ""
echo "3. Копирование SSH ключей в целевые контейнеры..."

# Получение публичного ключа
PUBLIC_KEY=$(docker-compose exec -T ansible-master cat /root/.ssh/id_rsa.pub)

echo "Копирование ключа в nginx-server..."
docker-compose exec -T nginx-server bash -c "
    mkdir -p /root/.ssh
    echo '$PUBLIC_KEY' >> /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
"

echo "Копирование ключа в app-server..."
docker-compose exec -T app-server bash -c "
    mkdir -p /root/.ssh
    echo '$PUBLIC_KEY' >> /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
"

# Тестирование SSH соединений
echo ""
echo "4. Тестирование SSH соединений..."

echo "Тестирование подключения к nginx-server..."
if docker-compose exec -T ansible-master ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@nginx-server "echo '✅ Успешное подключение к nginx-server'" 2>/dev/null; then
    echo "✅ SSH подключение к nginx-server работает"
else
    echo "❌ SSH подключение к nginx-server не работает"
fi

echo "Тестирование подключения к app-server..."
if docker-compose exec -T ansible-master ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@app-server "echo '✅ Успешное подключение к app-server'" 2>/dev/null; then
    echo "✅ SSH подключение к app-server работает"
else
    echo "❌ SSH подключение к app-server не работает"
fi

# Тестирование Ansible ping
echo ""
echo "5. Тестирование Ansible..."

echo "Проверка доступности хостов через Ansible..."
docker-compose exec -T ansible-master ansible -i /inventory/hosts all -m ping

echo ""
echo "6. Запуск Ansible плейбуков..."

echo "Запуск плейбука для nginx..."
docker-compose exec -T ansible-master ansible-playbook -i /inventory/hosts /ansible/nginx.yml

echo ""
echo "Запуск плейбука для приложения..."
docker-compose exec -T ansible-master ansible-playbook -i /inventory/hosts /ansible/app.yml

echo ""
echo "========================================"
echo "🎯 Настройка SSH завершена!"
echo "✅ SSH ключи настроены"
echo "✅ Ansible может подключаться к целевым хостам"
echo "✅ Плейбуки выполнены успешно"

echo ""
echo "📋 Следующие шаги:"
echo "   - Запустить проверку инфраструктуры: ./check_infrastructure.sh"
echo "   - Проверить веб-интерфейсы в браузере"
echo "   - Проверить логи: docker-compose logs"