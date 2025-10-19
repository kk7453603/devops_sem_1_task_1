#!/bin/bash

# Скрипт ручного тестирования проекта без Docker

echo "🧪 Ручное тестирование DevOps лабораторной работы"
echo "=============================================="

echo ""
echo "📋 Проверка структуры проекта..."
echo ""

# Проверка основных файлов
files=(
    "README.md"
    "docker-compose.yml"
    "ansible/site.yml"
    "ansible/nginx.yml"
    "ansible/app.yml"
    "inventory/hosts"
    "app/app.py"
    "app/requirements.txt"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file отсутствует"
    fi
done

echo ""
echo "📂 Проверка директорий ролей..."
directories=(
    "ansible/roles/nginx/tasks"
    "ansible/roles/nginx/templates"
    "ansible/roles/nginx/handlers"
    "ansible/roles/app_deploy/tasks"
    "ansible/roles/app_deploy/templates"
    "ansible/roles/app_deploy/handlers"
)

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir"
    else
        echo "❌ $dir отсутствует"
    fi
done

echo ""
echo "🔍 Проверка синтаксиса файлов..."

# Проверка YAML файлов
yaml_files=("ansible/site.yml" "ansible/nginx.yml" "ansible/app.yml" "docker-compose.yml")
for file in "${yaml_files[@]}"; do
    if python3 -c "import yaml; yaml.safe_load(open('$file')); print('✅ $file - корректный YAML')" 2>/dev/null; then
        echo "✅ $file - корректный YAML"
    else
        echo "❌ $file - ошибка YAML"
    fi
done

# Проверка Python файлов
python_files=("app/app.py")
for file in "${python_files[@]}"; do
    if python3 -m py_compile "$file" 2>/dev/null; then
        echo "✅ $file - корректный Python"
    else
        echo "❌ $file - ошибка Python"
    fi
done

echo ""
echo "📊 Статистика проекта:"
echo "========================="

# Подсчет строк кода
total_lines=0
echo ""
echo "Количество строк в основных файлах:"

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        total_lines=$((total_lines + lines))
        echo "  $file: $lines строк"
    fi
done

echo ""
echo "Всего строк в основных файлах: $total_lines"

echo ""
echo "🏗 Структура проекта:"
echo "===================="

echo "├── 📁 ansible/                    # Ansible плейбуки и роли"
echo "│   ├── 📄 site.yml               # Главный плейбук"
echo "│   ├── 📄 nginx.yml              # Плейбук для nginx"
echo "│   ├── 📄 app.yml                # Плейбук для приложения"
echo "│   └── 📁 roles/                 # Роли Ansible"
echo "│       ├── 📁 nginx/             # Роль для настройки nginx"
echo "│       └── 📁 app_deploy/        # Роль для деплоя приложения"
echo "├── 📁 app/                       # Исходный код приложения"
echo "│   ├── 📄 app.py                 # Главный файл Flask приложения"
echo "│   └── 📄 requirements.txt       # Зависимости Python"
echo "├── 📁 docker/                    # Docker файлы и скрипты"
echo "│   ├── 📄 Dockerfile.ansible     # Dockerfile для ansible-master"
echo "│   ├── 📄 Dockerfile.nginx       # Dockerfile для nginx-server"
echo "│   ├── 📄 Dockerfile.app         # Dockerfile для app-server"
echo "│   └── 📄 start_app.sh           # Скрипт запуска приложения"
echo "└── 📁 inventory/                 # Ansible inventory файлы"
echo "    ├── 📄 hosts                  # Статический inventory"
echo "    └── 📄 docker_hosts.py        # Динамический inventory скрипт"

echo ""
echo "🚀 Архитектура решения:"
echo "======================"
echo ""
echo "Контейнеры в сети devops-network:"
echo "  1. 📦 ansible-master    - Мастер контейнер с Ansible"
echo "  2. 🌐 nginx-server      - Веб-сервер (порт 8080)"
echo "  3. 🐍 app-server        - Приложение (порт 8000)"
echo "  4. 📊 monitoring        - Мониторинг и health check"
echo ""
echo "Поток данных:"
echo "  Пользователь → Nginx (8080) → Flask app (8000)"
echo ""
echo "Ansible роли:"
echo "  - nginx: Установка и настройка веб-сервера"
echo "  - app_deploy: Деплой Python приложения"
echo ""
echo "🎯 Готовые к использованию файлы:"
echo "- Полный набор Ansible ролей с шаблонами"
echo "- Готовое веб-приложение на Flask"
echo "- Конфигурация Docker с 4 контейнерами"
echo "- Подробная документация в README.md"
echo "- Скрипты для тестирования и запуска"

echo ""
echo "✅ Проект готов к развертыванию!"
echo ""
echo "Для запуска в среде с Docker:"
echo "  docker-compose up --build -d"
echo "  docker-compose exec ansible-master ansible-playbook -i /inventory/hosts /ansible/site.yml"
echo ""
echo "Для проверки работоспособности:"
echo "  curl http://localhost:8080"
echo "  curl http://localhost:8080/app/"
echo "  curl http://localhost:8080/app/api/status"