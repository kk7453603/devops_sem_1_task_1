#!/usr/bin/env python3
"""
Динамический inventory скрипт для Docker контейнеров
Генерирует inventory на основе запущенных контейнеров
"""

import json
import subprocess
import sys
from collections import defaultdict

def get_docker_containers():
    """Получить список запущенных контейнеров"""
    try:
        result = subprocess.run([
            'docker', 'ps',
            '--format', '{{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'
        ], capture_output=True, text=True, check=True)

        containers = []
        for line in result.stdout.strip().split('\n'):
            if line:
                name, image, ports, status = line.split('\t', 3)
                containers.append({
                    'name': name,
                    'image': image,
                    'ports': ports,
                    'status': status
                })
        return containers
    except subprocess.CalledProcessError:
        return []

def generate_inventory():
    """Сгенерировать Ansible inventory"""
    containers = get_docker_containers()

    inventory = {
        '_meta': {
            'hostvars': {}
        },
        'all': {
            'children': ['servers']
        },
        'servers': {
            'children': ['nginx_servers', 'app_servers']
        },
        'nginx_servers': {
            'hosts': {},
            'vars': {
                'ansible_connection': 'docker',
                'ansible_user': 'root',
                'nginx_port': 80,
                'web_root': '/var/www/html'
            }
        },
        'app_servers': {
            'hosts': {},
            'vars': {
                'ansible_connection': 'docker',
                'ansible_user': 'root',
                'app_dir': '/opt/myapp',
                'app_user': 'myapp',
                'app_port': 8000,
                'app_host': '0.0.0.0'
            }
        }
    }

    for container in containers:
        name = container['name']

        # Определение типа контейнера по имени
        if 'nginx' in name:
            inventory['nginx_servers']['hosts'][name] = {
                'ansible_host': name
            }
        elif 'app' in name:
            inventory['app_servers']['hosts'][name] = {
                'ansible_host': name
            }

        # Добавление переменных для каждого хоста
        inventory['_meta']['hostvars'][name] = {
            'ansible_connection': 'docker',
            'ansible_user': 'root',
            'container_name': name,
            'container_image': container['image'],
            'container_ports': container['ports'],
            'container_status': container['status']
        }

    return inventory

def main():
    """Главная функция"""
    if len(sys.argv) > 1 and sys.argv[1] == '--list':
        inventory = generate_inventory()
        print(json.dumps(inventory, indent=2))
    elif len(sys.argv) > 1 and sys.argv[1].startswith('--host'):
        # Для конкретного хоста возвращаем пустой словарь
        print(json.dumps({}))
    else:
        # Вывод помощи
        print("Использование:")
        print("  {} --list    - показать весь inventory".format(sys.argv[0]))
        print("  {} --host <hostname> - показать переменные для хоста".format(sys.argv[0]))

if __name__ == '__main__':
    main()