# Time Tracker API

Этот проект реализует тайм-трекер с использованием языка программирования Golang и базы данных PostgreSQL. 

## Функциональность

- **Получение данных пользователей**:
  - Фильтрация по всем полям.
  - Пагинация.
  - Получение трудозатрат по пользователю за период с сортировкой от большей к меньшей затрате времени.
- **Управление задачами**:
  - Начать отсчет времени по задаче для пользователя.
  - Закончить отсчет времени по задаче для пользователя.
- **Управление пользователями**:
  - Удаление пользователя.
  - Изменение данных пользователя.
  - Добавление нового пользователя по номеру паспорта.


## Требования

- Go 1.19+
- Docker
- Docker Compose

## Структура проекта

- **cmd/**: точка входа приложения.
- **internal/delivery/**: слой доставки, реализующий REST API.
- **internal/repository/**: слой доступа к данным, работа с базой данных PostgreSQL.
- **internal/service/**: слой бизнес-логики.
- **internal/models/**: определения моделей данных.

## Настройки сервиса находяться в файле .env

1) `Docker_Port=8000`- Порт, на котором будет работать ваше Go-приложение

2) `DB_USER=postgres`- Имя пользователя для подключения к базе данных PostgreSQL

3) `DB_PASSWORD=yourpassword`- Пароль для подключения к базе данных PostgreSQL

4) `DB_NAME=yourdbname` - Имя базы данных PostgreSQL

5) `DB_PORT=5432`- Порт для подключения к базе данных PostgreSQL

6) `DB_HOST=postgres`- Хост для подключения к базе данных PostgreSQL, указываем имя сервиса из docker-compose

7) `DEBUG=on`- Флаг для включения режима отладки

8) `Service_Url=:8000` - URL, по которому будет доступен сервис

9) `API_URL=http://localhost:8000/info` - URL внешнего API для получения данных о пользователе по номеру паспорта

10) `DB_MIGRATIONS_PATH=file://internal/migrations` - путь, по которому храняться миграции к БД

## API routes

`GET /get_users`: получение данных пользователей с фильтрацией и пагинацией.

`GET /get_user_tasks`: получение трудозатрат по пользователю за период.

`POST /start_user_task`: начать отсчет времени по задаче для пользователя.

`POST /stop_user_task`: закончить отсчет времени по задаче для пользователя.

`POST /add_user`: добавление нового пользователя.

`POST /edit_user`: изменение данных пользователя.

`POST /delete_user`: удаление пользователя.

`GET /swagger/*`: документация Swagger.

## Логирование

Код покрыт debug и info логами для упрощения отладки и мониторинга.

## Запуск web сервиса
Перед запуском необходимо установить в .env файле полный путь до внешнего API ``API_URL``.


1) Запуск в Docker compose:
    -  ``docker-compose up --build``
2) Запуск вручную:
    - ``go run /cmd/main.go``
3) Сборка исполняемого файла:
    - ``go build -o time-tracker ./cmd``



### Helm charts (Автоматическая установка в кластере kubernetes)

Обновленный Helm chart включает enterprise-grade возможности: безопасность, мониторинг, масштабируемость и автоматизацию.

#### Предварительные требования

- Kubernetes кластер (1.19+)
- Helm 3.x
- kubectl
- (Опционально) Prometheus Operator для мониторинга

#### Подготовка кластера

1. **Установите Helm** (если не установлен)
2. **Добавьте запись в /etc/hosts**:
   ```bash
   echo "127.0.0.1 myapp.local" | sudo tee -a /etc/hosts
   ```

3. **Установите Ingress Controller** (если не установлен):
   ```bash
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   helm install ingress-nginx ingress-nginx/ingress-nginx --namespace default --create-namespace
   ```

4. **(Опционально) Установите Prometheus Operator** для мониторинга:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
   ```

#### Установка приложения

1. **Перейдите в директорию проекта**:
   ```bash
   cd /path/to/your/project
   ```

2. **Сгенерируйте values файл с сертификатами**:
   ```bash
   ./generate-values.sh
   ```

3. **Установите зависимости**:
   ```bash
   cd myapp
   helm dependency build
   cd ..
   ```

4. **Установите приложение**:
   ```bash
   helm install myapp ./myapp --namespace default -f ./myapp/values-prod.yaml
   ```

#### Проверка установки

```bash
# Проверьте статус подов
kubectl get pods --namespace default

# Проверьте сервисы
kubectl get services --namespace default

# Запустите тесты
helm test myapp --namespace default

# Проверьте доступность
curl https://myapp.local/swagger/index.html
```

#### Управление приложением

**Обновление**:
```bash
helm upgrade myapp ./myapp --namespace default -f ./myapp/values-prod.yaml
```

**Удаление**:
```bash
helm uninstall myapp --namespace default
```

#### Конфигурация

##### Production настройки (values-prod.yaml)

```yaml
# Базовые настройки
replicaCount: 2
image:
  tag: "v1.0.0"

# TLS сертификаты (автоматически генерируются скриптом)
tls:
  crt: <base64-encoded-cert>
  key: <base64-encoded-key>

# Production фичи
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true

backup:
  enabled: true
  schedule: "0 2 * * *"

networkPolicy:
  enabled: true

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
```

##### Environment-specific конфигурация

Создайте отдельные файлы для разных сред:

- `values-dev.yaml` - для разработки
- `values-staging.yaml` - для тестирования
- `values-prod.yaml` - для production

#### Возможности обновленного Helm chart

- ✅ **Безопасность**: Kubernetes секреты, RBAC, NetworkPolicy
- ✅ **Масштабируемость**: HPA, resource limits, affinity rules
- ✅ **Надежность**: Health checks, persistence, automated backups
- ✅ **Мониторинг**: Prometheus ServiceMonitor, метрики
- ✅ **Конфигурация**: ConfigMaps, environment variables
- ✅ **CI/CD**: Production-ready с Helm best practices

#### Troubleshooting

**Проблема**: `Error: INSTALLATION FAILED: unable to build kubernetes objects`

**Решение**: Убедитесь, что сертификаты правильно закодированы в base64:
```bash
./generate-values.sh
```

**Проблема**: `Error: INSTALLATION FAILED: Secret "tls" exists`

**Решение**: Очистите старые ресурсы:
```bash
kubectl delete secrets --selector app.kubernetes.io/name=myapp --namespace default
kubectl delete pvc --selector app.kubernetes.io/name=myapp --namespace default
```

**Проблема**: Приложение не запускается

**Решение**: Проверьте логи:
```bash
kubectl logs -l app=myapp --namespace default
kubectl describe pod <pod-name> --namespace default
```