#!/bin/bash

# Скрипт тестирования Docker конфигурации

echo "🐳 Тестирование Docker конфигурации..."
echo "====================================="

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен"
    exit 1
fi

echo "✅ Docker и Docker Compose установлены"

# Проверка синтаксиса docker-compose.yml
echo ""
echo "🔍 Проверка синтаксиса docker-compose.yml..."
if docker-compose config > /dev/null 2>&1; then
    echo "✅ Синтаксис docker-compose.yml корректен"
else
    echo "❌ Ошибка в синтаксисе docker-compose.yml"
    exit 1
fi

# Проверка Dockerfile файлов
echo ""
echo "🔍 Проверка Dockerfile файлов..."

dockerfiles=("docker/Dockerfile.ansible" "docker/Dockerfile.nginx" "docker/Dockerfile.app")
for dockerfile in "${dockerfiles[@]}"; do
    if [ -f "$dockerfile" ]; then
        echo "✅ Файл $dockerfile найден"
        # Проверка синтаксиса Dockerfile
        if docker build --dry-run -f "$dockerfile" . > /dev/null 2>&1; then
            echo "✅ Синтаксис $dockerfile корректен"
        else
            echo "❌ Ошибка в синтаксисе $dockerfile"
        fi
    else
        echo "❌ Файл $dockerfile не найден"
    fi
done

# Проверка наличия необходимых файлов
echo ""
echo "📁 Проверка наличия необходимых файлов..."

required_files=(
    "ansible/site.yml"
    "ansible/nginx.yml"
    "ansible/app.yml"
    "inventory/hosts"
    "app/app.py"
    "app/requirements.txt"
    "docker-compose.yml"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file найден"
    else
        echo "❌ $file не найден"
    fi
done

# Проверка директорий ролей
echo ""
echo "📂 Проверка директорий ролей..."

roles_dirs=(
    "ansible/roles/nginx/tasks"
    "ansible/roles/nginx/templates"
    "ansible/roles/nginx/handlers"
    "ansible/roles/app_deploy/tasks"
    "ansible/roles/app_deploy/templates"
    "ansible/roles/app_deploy/handlers"
)

for dir in "${roles_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ Директория $dir найдена"
    else
        echo "❌ Директория $dir не найдена"
    fi
done

echo ""
echo "🎯 Тестирование завершено!"
echo ""
echo "Следующие шаги для запуска:"
echo "1. docker-compose up --build -d"
echo "2. docker-compose exec ansible-master ansible-playbook -i /inventory/hosts /ansible/site.yml"
echo "3. Открыть браузер: http://localhost:8080"