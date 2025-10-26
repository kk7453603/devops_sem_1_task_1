# DevOps Лабораторная работа №3
## Автоматизация деплоя веб-приложения с помощью Ansible и Docker

### Описание проекта

Этот проект демонстрирует автоматизированное развертывание веб-приложения с использованием:
- **🐳 Docker** - для создания изолированных контейнеров
- **⚙️ Ansible** - для автоматизации настройки и деплоя
- **🌐 Nginx** - как веб-сервер и reverse proxy
- **🐍 Python Flask** - как веб-фреймворк для приложения

### Архитектура

Проект состоит из 4 контейнеров в единой Docker сети, использующих чистые образы и автоматизацию через Ansible:

1. **ansible-master** - мастер контейнер с Ansible для автоматизации деплоя
2. **nginx-server** - чистый контейнер Ubuntu, настраиваемый Ansible как веб-сервер и reverse proxy
3. **app-server** - чистый контейнер Ubuntu, настраиваемый Ansible для деплоя веб-приложения
4. **monitoring-helper** - вспомогательный контейнер для мониторинга состояния сервисов

```
┌─────────────────┐    SSH/Ansible     ┌─────────────────┐
│  ansible-master │───────────────────▶│   nginx-server  │
│                 │                    │   (port 8080)   │
│  - Ansible      │                    │                 │
│  - SSH ключи    │                    │  - Чистый Ubuntu│
│  - Inventory    │                    │  - Установка    │
│  - Плейбуки     │                    │    nginx через  │
└─────────────────┘                    │    Ansible      │
       │                               │  - Reverse proxy│
       │ SSH/Ansible                   └─────────────────┘
       │                                      │
       │                                      │ HTTP
       │                               ┌─────────────────┐
       └──────────────────────────────▶│   app-server    │
                                       │   (port 8000)   │
                                       │                 │
                                       │  - Чистый Ubuntu│
                                       │  - Деплой app   │
                                       │    через Ansible│
                                       │  - Flask +      │
                                       │    Gunicorn     │
                                       └─────────────────┘

                                       ┌─────────────────┐
                                       │ monitoring-help │
                                       │                 │
                                       │  - Health check │
                                       │  - Логирование  │
                                       └─────────────────┘
```

**Ключевые особенности обновленной архитектуры:**
- ✅ Все целевые контейнеры являются "чистыми" (без предустановленных сервисов)
- ✅ Деплой осуществляется исключительно через Ansible
- ✅ Nginx настроен как reverse proxy к приложению
- ✅ SSH соединения между контейнерами для работы Ansible
- ✅ Автоматическая проверка работоспособности

### Структура проекта

```
devops_sem_1_task_3/
├── README.md                    # Этот файл
├── docker-compose.yml          # Конфигурация Docker контейнеров
├── ansible/                    # Ansible плейбуки и роли
│   ├── site.yml               # Главный плейбук
│   ├── nginx.yml              # Плейбук для nginx
│   ├── app.yml                # Плейбук для приложения
│   └── roles/                 # Роли Ansible
│       ├── nginx/             # Роль для настройки nginx
│       └── app_deploy/        # Роль для деплоя приложения
├── app/                       # Исходный код приложения
│   ├── app.py                 # Главный файл Flask приложения
│   ├── requirements.txt       # Зависимости Python
│   └── README.md              # Документация приложения
├── docker/                    # Docker файлы и скрипты
│   ├── Dockerfile.ansible     # Dockerfile для ansible-master
│   ├── Dockerfile.nginx       # Dockerfile для nginx-server
│   ├── Dockerfile.app         # Dockerfile для app-server
│   └── start_app.sh           # Скрипт запуска приложения
└── inventory/                 # Ansible inventory файлы
    ├── hosts                  # Статический inventory
    └── docker_hosts.py        # Динамический inventory скрипт
```

## 🚀 Быстрый старт

### Предварительные требования

- Docker и Docker Compose
- Минимум 2GB свободной памяти

### Шаг 1: Клонирование проекта

```bash
git clone <repository-url>
cd devops_sem_1_task_3
```

### Шаг 2: Сборка и запуск чистых контейнеров

```bash
# Сборка образов и запуск всех контейнеров
docker-compose up --build -d

# Проверка статуса контейнеров
docker-compose ps
```

Ожидаемый результат:
```
      Name                    Command              State           Ports         
--------------------------------------------------------------------------------
ansible-master      /usr/sbin/sshd -D              Up      22/tcp                
app-server          /usr/sbin/sshd -D              Up      22/tcp, 8000/tcp      
monitoring-helper   sh -c apk add --no-cach ...   Up                            
nginx-server        /usr/sbin/sshd -D              Up      22/tcp, 80/tcp        
```

### Шаг 3: Настройка SSH для Ansible

```bash
# Настройка SSH ключей и запуск Ansible плейбуков
chmod +x setup_ansible_ssh.sh 
./setup_ansible_ssh.sh
```

Этот скрипт автоматически:
- Создает SSH ключи в ansible-master контейнере
- Копирует ключи в целевые контейнеры
- Тестирует SSH соединения
- Запускает Ansible плейбуки для настройки nginx и деплоя приложения

### Шаг 4: Проверка работоспособности

```bash
# Автоматическая проверка всей инфраструктуры
chmod +x check_infrastructure.sh
./check_infrastructure.sh
```

Ручная проверка:
```bash
# Проверка главной страницы nginx
curl http://localhost:8080

# Проверка приложения через nginx (reverse proxy)
curl http://localhost:8080/app/

# Проверка API приложения
curl http://localhost:8080/app/api/status

# Проверка health check
curl http://localhost:8080/app/health
```

### Шаг 5: Ручной запуск Ansible плейбуков (опционально)

```bash
# Подключение к ansible-master контейнеру
docker-compose exec ansible-master bash

# Запуск полного деплоя
ansible-playbook -i /inventory/hosts /ansible/site.yml

# Или запуск отдельных плейбуков
ansible-playbook -i /inventory/hosts /ansible/nginx.yml
ansible-playbook -i /inventory/hosts /ansible/app.yml

# Тестирование подключения
ansible -i /inventory/hosts all -m ping
```

## 📋 Подробная инструкция

### Этап 1: Подготовка окружения

1. **Проверка Docker**
   ```bash
   docker --version
   docker-compose --version
   ```

2. **Сборка образов**
   ```bash
   # Сборка всех образов
   docker-compose build

   # Или сборка отдельных образов
   docker-compose build ansible-master
   docker-compose build nginx-server
   docker-compose build app-server
   ```

### Этап 2: Запуск инфраструктуры

1. **Запуск всех контейнеров**
   ```bash
   docker-compose up -d
   ```

2. **Проверка сети**
   ```bash
   # Проверка созданной сети
   docker network ls | grep devops

   # Проверка контейнеров в сети
   docker network inspect devops-network
   ```

3. **Проверка логов**
   ```bash
   # Логи всех контейнеров
   docker-compose logs

   # Логи конкретного контейнера
   docker-compose logs nginx-server
   docker-compose logs app-server
   ```

### Этап 3: Ansible автоматизация

1. **Подготовка SSH ключей**
   ```bash
   # Генерация SSH ключей в контейнере
   docker-compose exec ansible-master ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N ""

   # Копирование ключей в целевые контейнеры
   docker-compose exec ansible-master ssh-copy-id root@nginx-server
   docker-compose exec ansible-master ssh-copy-id root@app-server
   ```

2. **Тестирование подключения**
   ```bash
   docker-compose exec ansible-master ansible -i /inventory/hosts all -m ping
   ```

3. **Запуск плейбуков**
   ```bash
   # Полный деплой
   docker-compose exec ansible-master ansible-playbook -i /inventory/hosts /ansible/site.yml

   # Деплой только nginx
   docker-compose exec ansible-master ansible-playbook -i /inventory/hosts /ansible/nginx.yml

   # Деплой только приложения
   docker-compose exec ansible-master ansible-playbook -i /inventory/hosts /ansible/app.yml
   ```

### Этап 4: Проверка работоспособности

1. **Веб-интерфейс**
   - Nginx сервер: http://localhost:8080
   - Веб-приложение: http://localhost:8080/app/
   - API статус: http://localhost:8080/app/api/status

2. **Мониторинг**
   ```bash
   # Логи мониторинга
   docker-compose logs monitoring-helper

   # Проверка через API
   curl http://localhost:8080/app/health
   curl http://localhost:8080/app/api/status
   ```

3. **Статус сервисов**
   ```bash
   # Статус контейнеров
   docker-compose ps

   # Детальная информация
   docker-compose top

   # Использование ресурсов
   docker stats
   ```

## 🔧 Конфигурация

### Переменные окружения

**Для приложения:**
```bash
DEBUG=false                    # Режим отладки
APP_HOST=0.0.0.0              # Хост для запуска
APP_PORT=8000                 # Порт для запуска
SECRET_KEY=demo-secret-key    # Секретный ключ
```

**Для nginx:**
```bash
NGINX_PORT=80                 # Порт nginx
CLIENT_MAX_BODY_SIZE=16M      # Максимальный размер тела запроса
```

### Кастомизация

1. **Изменение портов**
   ```yaml
   # В docker-compose.yml
   ports:
     - "8081:80"  # Изменить порт nginx
   ```

2. **Добавление volumes**
   ```yaml
   volumes:
     - ./custom-config:/etc/nginx/conf.d  # Кастомная конфигурация
   ```

## 🛠 Разработка и отладка

### Локальная разработка

1. **Запуск приложения локально**
   ```bash
   cd app/
   pip install -r requirements.txt
   python3 app.py
   ```

2. **Тестирование Ansible ролей**
   ```bash
   # Синтаксис плейбуков
   ansible-playbook --syntax-check ansible/site.yml

   # Проверка ролей
   ansible-lint ansible/roles/
   ```

### Отладка контейнеров

1. **Подключение к контейнеру**
   ```bash
   docker-compose exec nginx-server bash
   docker-compose exec app-server bash
   docker-compose exec ansible-master bash
   ```

2. **Просмотр процессов**
   ```bash
   docker-compose top
   docker-compose exec app-server ps aux
   ```

## ✅ Проверка работоспособности

### Автоматическая проверка

Проект включает автоматические скрипты для проверки всей инфраструктуры:

```bash
# Полная проверка инфраструктуры (рекомендуется)
./check_infrastructure.sh

# Настройка SSH и запуск Ansible плейбуков
./setup_ansible_ssh.sh
```

**Что проверяет `check_infrastructure.sh`:**
- ✅ Статус всех Docker контейнеров
- ✅ SSH соединения между контейнерами
- ✅ Доступность веб-сервисов (nginx, приложение)
- ✅ Работу API endpoints и health check
- ✅ Логи и процессы внутри контейнеров
- ✅ Критические сервисы для продакшена

### Ручная проверка

**1. Проверка контейнеров:**
```bash
# Статус контейнеров
docker-compose ps

# Логи в реальном времени
docker-compose logs -f

# Проверка сети
docker network inspect devops-network
```

**2. Проверка веб-сервисов:**
```bash
# Главная страница nginx
curl http://localhost:8080

# Приложение через reverse proxy
curl http://localhost:8080/app/

# API статус приложения
curl http://localhost:8080/app/api/status

# Health check
curl http://localhost:8080/app/health
```

**3. Проверка SSH и Ansible:**
```bash
# Подключение к ansible-master
docker-compose exec ansible-master bash

# Проверка SSH соединений
ssh root@nginx-server "echo '✅ nginx доступен'"
ssh root@app-server "echo '✅ app доступен'"

# Проверка Ansible
ansible -i /inventory/hosts all -m ping

# Запуск отдельных плейбуков
ansible-playbook -i /inventory/hosts /ansible/nginx.yml
ansible-playbook -i /inventory/hosts /ansible/app.yml
```

**4. Проверка процессов:**
```bash
# Процессы nginx
docker-compose exec nginx-server ps aux | grep nginx

# Процессы приложения
docker-compose exec app-server ps aux | grep python

# Systemd сервисы
docker-compose exec nginx-server systemctl status nginx
docker-compose exec app-server systemctl status myapp
```

### Ожидаемые результаты

**Успешная настройка:**
```
✅ Все контейнеры запущены
✅ SSH соединения работают
✅ Ansible плейбуки выполнены без ошибок
✅ Nginx отвечает на порту 8080
✅ Приложение доступно по /app/
✅ API endpoints возвращают корректные данные
✅ Health check показывает "healthy"
```

## 📊 Мониторинг и логи

### Логи приложения
```bash
# Все логи
docker-compose logs -f

# Логи приложения
docker-compose logs -f app-server

# Логи nginx
docker-compose logs -f nginx-server

# Логи мониторинга
docker-compose logs -f monitoring-helper
```

### Метрики
```bash
# Использование ресурсов
docker stats

# Детальная информация о контейнере
docker inspect app-server

# Логи системы
docker-compose exec app-server journalctl -u myapp
```

## 🧪 Тестирование

### Автоматические тесты

1. **Health check endpoints**
   ```bash
   # Тест health check
   curl -f http://localhost:8080/app/health

   # Тест API статус
   curl -f http://localhost:8080/app/api/status
   ```

2. **Нагрузочное тестирование**
   ```bash
   # Простое нагрузочное тестирование
   for i in {1..10}; do
       curl -s http://localhost:8080/app/ > /dev/null &
   done
   ```

### Ручное тестирование

1. **Проверка веб-интерфейса**
   - Открыть браузер
   - Перейти на http://localhost:8080
   - Проверить отображение главной страницы
   - Перейти на http://localhost:8080/app/
   - Проверить работу API

2. **Проверка функциональности**
   - Проверить ответы API
   - Проверить логи приложения
   - Проверить статус сервисов

## 🛑 Остановка и очистка

### Остановка проекта
```bash
# Остановка всех контейнеров
docker-compose down

# Остановка с удалением volumes
docker-compose down -v

# Полная очистка
docker-compose down -v --remove-orphans
docker system prune -f
```

### Очистка ресурсов
```bash
# Удаление образов
docker-compose down --rmi all

# Очистка volumes
docker volume prune -f

# Очистка сети
docker network prune -f
```

## 📁 Исходный код приложения

Исходный код демо веб-приложения находится в директории `app/`:

- `app.py` - Главный файл Flask приложения
- `requirements.txt` - Зависимости Python
- `README.md` - Документация приложения

Приложение включает:
- Главную страницу с информацией
- API endpoints для мониторинга
- Health check функциональность
- Конфигурацию через переменные окружения

## 🔐 Безопасность

### Рекомендации по безопасности

1. **Сетевые настройки**
   ```yaml
   networks:
     devops-network:
       internal: true  # Изоляция сети
   ```

2. **Переменные окружения**
   ```bash
   # Использовать сильные секретные ключи
   SECRET_KEY=super-secure-key-$(date +%s)
   ```

3. **Ограничения ресурсов**
   ```yaml
   deploy:
     resources:
       limits:
         memory: 512M
   ```

## 🚨 Troubleshooting

### Распространенные проблемы

1. **Контейнеры не запускаются**
   ```bash
   # Проверка логов
   docker-compose logs

   # Проверка ресурсов
   docker system df

   # Перезапуск Docker
   sudo systemctl restart docker
   ```

2. **Ansible не подключается**
   ```bash
   # Проверка SSH ключей
   docker-compose exec ansible-master ssh -v root@nginx-server

   # Проверка inventory
   docker-compose exec ansible-master ansible -i /inventory/hosts all -m ping
   ```

3. **Приложение недоступно**
   ```bash
   # Проверка портов
   docker-compose port app-server

   # Проверка логов приложения
   docker-compose logs app-server

   # Проверка health check
   curl http://localhost:8080/app/health
   ```

### Полезные команды

```bash
# Проверка запущенных контейнеров
docker ps | grep devops

# Проверка сетевых подключений
docker network inspect devops-network

# Проверка использования ресурсов
docker stats --no-stream

# Проверка образов
docker images | grep devops

# Очистка неиспользуемых ресурсов
docker system prune -f
```

## 📈 Производительность

### Оптимизация

1. **Многоэтапная сборка образов**
   ```dockerfile
   # Использовать многоэтапную сборку для уменьшения размера
   FROM python:3.9-slim as builder
   # ... сборка зависимостей

   FROM python:3.9-slim
   # ... финальный образ
   ```

2. **Кеширование слоев**
   ```dockerfile
   # Копировать зависимости первыми
   COPY requirements.txt .
   RUN pip install -r requirements.txt

   # Затем копировать код
   COPY . .
   ```

## 📚 Дополнительная информация

### Используемые технологии

- **Docker**: 24.0+
- **Docker Compose**: 2.20+
- **Ansible**: 8.0+
- **Python**: 3.9+
- **Flask**: 2.3+
- **Nginx**: 1.24+
- **Ubuntu**: 22.04 LTS

### Рекомендуемая литература

1. [Документация Docker](https://docs.docker.com/)
2. [Документация Ansible](https://docs.ansible.com/)
3. [Руководство Flask](https://flask.palletsprojects.com/)
4. [Документация Nginx](https://nginx.org/ru/docs/)

### Структура ролей Ansible

```
roles/
├── nginx/
│   ├── tasks/main.yml      # Основные задачи
│   ├── handlers/main.yml   # Обработчики событий
│   ├── vars/main.yml       # Переменные роли
│   ├── templates/          # Jinja2 шаблоны
│   └── defaults/main.yml   # Переменные по умолчанию
└── app_deploy/
    ├── tasks/main.yml      # Задачи деплоя
    ├── handlers/main.yml   # Обработчики
    ├── vars/main.yml       # Переменные
    ├── templates/          # Шаблоны конфигурации
    └── defaults/main.yml   # Переменные по умолчанию
```

## 🎯 Результаты выполнения

После успешного выполнения лабораторной работы вы получите:

- ✅ Полностью автоматизированное развертывание веб-приложения
- ✅ Изолированную среду разработки в Docker контейнерах
- ✅ Настроенный веб-сервер Nginx с reverse proxy
- ✅ Мониторинг и health check endpoints
- ✅ Масштабируемую архитектуру для дальнейшего развития

## 📝 Заключение

Этот проект демонстрирует современные практики DevOps:

1. **Контейнеризация** - изоляция приложений и сервисов
2. **Автоматизация** - развертывание через Ansible
3. **Мониторинг** - отслеживание состояния сервисов
4. **Масштабируемость** - легко добавлять новые сервисы
5. **Документирование** - подробная инструкция по использованию

Проект готов к использованию в продакшене с минимальными доработками!

## Скриншоты
![1](img/image.png)
