#!/usr/bin/env python3
"""
Простое веб-приложение для демонстрации деплоя через Ansible
"""

import os
from datetime import datetime
from flask import Flask, jsonify, render_template_string

# Создание Flask приложения
app = Flask(__name__)

# Загрузка конфигурации из переменных окружения
app.config['DEBUG'] = os.getenv('DEBUG', 'False').lower() == 'true'
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key')

@app.route('/')
def index():
    """Главная страница приложения"""
    html_content = """
    <!DOCTYPE html>
    <html lang="ru">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Демо приложение</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f5f5f5;
            }
            .container {
                background-color: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .header {
                text-align: center;
                color: #333;
                margin-bottom: 30px;
            }
            .info {
                margin: 20px 0;
                padding: 15px;
                background-color: #e8f4f8;
                border-left: 4px solid #2196F3;
                border-radius: 4px;
            }
            .status {
                display: inline-block;
                padding: 5px 15px;
                border-radius: 20px;
                color: white;
                font-weight: bold;
            }
            .success { background-color: #4CAF50; }
            .info-status { background-color: #2196F3; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚀 Демо веб-приложение</h1>
                <p>Успешно развернуто через Ansible!</p>
            </div>

            <div class="info">
                <h3>Информация о приложении:</h3>
                <p><strong>Время запуска:</strong> {{ timestamp }}</p>
                <p><strong>Статус:</strong> <span class="status success">Работает</span></p>
                <p><strong>Режим отладки:</strong> <span class="status {{ 'info-status' if debug else 'success' }}">{{ 'Включен' if debug else 'Отключен' }}</span></p>
                <p><strong>Хост:</strong> {{ host }}</p>
                <p><strong>Порт:</strong> {{ port }}</p>
            </div>

            <div class="info">
                <h3>О проекте:</h3>
                <p>Это демонстрационное приложение было развернуто с помощью:</p>
                <ul>
                    <li>🐳 Docker контейнеров</li>
                    <li>⚙️ Ansible плейбуков</li>
                    <li>🌐 Nginx веб-сервера</li>
                    <li>🐍 Python Flask фреймворка</li>
                </ul>
            </div>

            <div class="info">
                <h3>API Endpoints:</h3>
                <p>Попробуйте API: <a href="/api/status" target="_blank">/api/status</a></p>
                <p>Health check: <a href="/health" target="_blank">/health</a></p>
            </div>
        </div>
    </body>
    </html>
    """

    return render_template_string(html_content,
                                timestamp=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                                debug=app.config['DEBUG'],
                                host=os.getenv('APP_HOST', 'localhost'),
                                port=os.getenv('APP_PORT', '8000'))

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'service': 'demo-app'
    })

@app.route('/api/status')
def api_status():
    """API статус endpoint"""
    return jsonify({
        'status': 'running',
        'message': 'Приложение успешно развернуто через Ansible!',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0',
        'environment': {
            'debug': app.config['DEBUG'],
            'host': os.getenv('APP_HOST'),
            'port': os.getenv('APP_PORT')
        }
    })

@app.errorhandler(404)
def not_found(error):
    """Обработчик 404 ошибки"""
    return jsonify({
        'error': 'Страница не найдена',
        'status_code': 404,
        'timestamp': datetime.now().isoformat()
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Обработчик 500 ошибки"""
    return jsonify({
        'error': 'Внутренняя ошибка сервера',
        'status_code': 500,
        'timestamp': datetime.now().isoformat()
    }), 500

if __name__ == '__main__':
    # Получение настроек из переменных окружения
    host = os.getenv('APP_HOST', '0.0.0.0')
    port = int(os.getenv('APP_PORT', '8000'))
    debug = os.getenv('DEBUG', 'False').lower() == 'true'

    print(f"Запуск приложения на {host}:{port}")
    print(f"Режим отладки: {'Включен' if debug else 'Отключен'}")

    app.run(host=host, port=port, debug=debug)