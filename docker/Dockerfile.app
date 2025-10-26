FROM ubuntu:22.04

LABEL maintainer="DevOps Lab"
LABEL description="Чистый контейнер для деплоя приложения через Ansible"

# Установка базовых зависимостей (без приложения)
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    net-tools \
    iputils-ping \
    dnsutils \
    systemd \
    sudo \
    openssh-server \
    git \
    && rm -rf /var/lib/apt/lists/*

# Настройка SSH сервера
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'root:ansible' | chpasswd

# Создание пользователя приложения (будет настроен Ansible)
RUN useradd -m -s /bin/bash myapp && \
    mkdir -p /opt/myapp /opt/myapp/logs && \
    chown -R myapp:myapp /opt/myapp

# Создание базовой структуры директорий
RUN mkdir -p /var/log/myapp

# Экспорт портов SSH и приложения
EXPOSE 22 8000

# Запуск SSH сервера и ожидание Ansible
CMD ["/usr/sbin/sshd", "-D"]