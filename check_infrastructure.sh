#!/bin/bash

# Скрипт проверки работоспособности всей инфраструктуры
# Автоматическая проверка контейнеров, сервисов и веб-интерфейсов

set -e

echo "🔍 Проверка инфраструктуры DevOps лаборатории..."
echo "================================================"

# Проверка запущенных контейнеров
echo ""
echo "1. Проверка контейнеров Docker..."
docker-compose ps

# Проверка сети
echo ""
echo "2. Проверка Docker сети..."
docker network ls | grep devops || echo "❌ Сеть devops-network не найдена"

# Проверка SSH соединений
echo ""
echo "3. Проверка SSH соединений с целевыми контейнерами..."

# Проверка nginx-server
if docker-compose exec -T ansible-master ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@nginx-server "echo '✅ SSH: nginx-server доступен'" 2>/dev/null; then
    echo "✅ SSH: nginx-server доступен"
else
    echo "❌ SSH: nginx-server недоступен"
fi

# Проверка app-server
if docker-compose exec -T ansible-master ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@app-server "echo '✅ SSH: app-server доступен'" 2>/dev/null; then
    echo "✅ SSH: app-server доступен"
else
    echo "❌ SSH: app-server недоступен"
fi

# Проверка веб-сервисов
echo ""
echo "4. Проверка веб-сервисов..."

# Проверка главной страницы nginx
echo "Проверка главной страницы nginx..."
if curl -s -f http://localhost:8080 > /dev/null; then
    echo "✅ Nginx главная страница доступна"
else
    echo "❌ Nginx главная страница недоступна"
fi

# Проверка приложения через nginx
echo "Проверка приложения через nginx..."
if curl -s -f http://localhost:8080/app/ > /dev/null; then
    echo "✅ Приложение доступно через nginx"
else
    echo "❌ Приложение недоступно через nginx"
fi

# Проверка API приложения
echo "Проверка API приложения..."
if curl -s -f http://localhost:8080/app/api/status | grep -q "running"; then
    echo "✅ API приложения работает"
else
    echo "❌ API приложения не работает"
fi

# Проверка health check
echo "Проверка health check..."
if curl -s -f http://localhost:8080/app/health | grep -q "healthy"; then
    echo "✅ Health check работает"
else
    echo "❌ Health check не работает"
fi

# Проверка логов
echo ""
echo "5. Проверка логов сервисов..."

# Логи nginx
echo "Логи nginx (последние 5 строк):"
docker-compose logs --tail=5 nginx-server

echo ""
echo "Логи приложения (последние 5 строк):"
docker-compose logs --tail=5 app-server

echo ""
echo "Логи мониторинга (последние 5 строк):"
docker-compose logs --tail=5 monitoring-helper

# Проверка процессов внутри контейнеров
echo ""
echo "6. Проверка процессов в контейнерах..."

echo "Процессы в nginx-server:"
docker-compose exec -T nginx-server ps aux | grep nginx || echo "❌ Nginx процессы не найдены"

echo ""
echo "Процессы в app-server:"
docker-compose exec -T app-server ps aux | grep python || echo "❌ Python процессы не найдены"

# Итоговая проверка
echo ""
echo "================================================"
echo "🎯 Итоговая проверка инфраструктуры:"

# Проверка всех критических сервисов
ALL_CHECKS_PASSED=true

# Критические проверки
if ! curl -s -f http://localhost:8080/app/health > /dev/null; then
    echo "❌ КРИТИЧЕСКАЯ ОШИБКА: Health check не работает"
    ALL_CHECKS_PASSED=false
fi

if ! curl -s -f http://localhost:8080/app/api/status > /dev/null; then
    echo "❌ КРИТИЧЕСКАЯ ОШИБКА: API приложения не работает"
    ALL_CHECKS_PASSED=false
fi

if ! curl -s -f http://localhost:8080 > /dev/null; then
    echo "❌ КРИТИЧЕСКАЯ ОШИБКА: Nginx не работает"
    ALL_CHECKS_PASSED=false
fi

if $ALL_CHECKS_PASSED; then
    echo ""
    echo "🎉 ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ УСПЕШНО!"
    echo "✅ Инфраструктура работает корректно"
    echo "🌐 Доступные endpoints:"
    echo "   - Главная страница: http://localhost:8080"
    echo "   - Приложение: http://localhost:8080/app/"
    echo "   - API статус: http://localhost:8080/app/api/status"
    echo "   - Health check: http://localhost:8080/app/health"
    exit 0
else
    echo ""
    echo "💥 ОБНАРУЖЕНЫ ПРОБЛЕМЫ В ИНФРАСТРУКТУРЕ!"
    echo "❌ Некоторые сервисы работают некорректно"
    exit 1
fi