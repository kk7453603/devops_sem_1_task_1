#!/bin/bash

# Проверяем наличие файлов
if [ ! -f "tls.crt" ] || [ ! -f "tls.key" ]; then
  echo "Error: tls.crt and tls.key files not found"
  exit 1
fi

# Генерируем values-prod.yaml
cat > myapp/values-prod.yaml << EOF
# Production values with embedded certificates
replicaCount: 2

image:
  repository: kirillkom/effective_go_app
  tag: "v1.0.0"
  pullPolicy: IfNotPresent

service:
  name: myapp-service
  type: NodePort
  port: 8000
  nodePort: 30007

ingress:
  enabled: true
  ingressClassName: nginx
  hostname: myapp.local
  path: /
  pathType: Prefix
  tls:
    enabled: true
    secretName: tls

postgres:
  enabled: true
  image:
    repository: postgres
    tag: "16"
  env:
    POSTGRES_USER: "postgres"
    POSTGRES_PASSWORD: "your_secure_password"
    POSTGRES_DB: "time_tracker"
  service:
    port: 5432
  persistence:
    size: "10Gi"

tls:
  crt: $(cat tls.crt | base64 -w 0)
  key: $(cat tls.key | base64 -w 0)

app:
  debug: "off"
  runMigrations: true

serviceAccount:
  create: true

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

monitoring:
  enabled: true
  serviceMonitor:
    enabled: true

backup:
  enabled: true
  schedule: "0 2 * * *"

networkPolicy:
  enabled: true

rbac:
  enabled: true
EOF

echo "Generated myapp/values-prod.yaml with base64 encoded certificates"
