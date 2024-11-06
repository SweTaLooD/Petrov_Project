## Проект: Обеспечение безопасности веб-приложения с помощью Nginx, MySQL и PHP

### Описание

Этот проект разворачивает безопасное веб-приложение на трех виртуальных машинах с использованием Nginx, MySQL и PHP. Веб-приложение защищено от сетевых атак и настраивается с помощью Ansible для автоматизации процесса развертывания. 

### Архитектура

1. **VM1**: Основная машина для управления (Ansible)
2. **VM2**: Веб-сервер с Nginx и PHP
3. **VM3**: Сервер базы данных MySQL

### Подготовка окружения

#### VM1 (Основная машина)

Используется для управления и автоматизации настройки других виртуальных машин с помощью Ansible.

- **Установите Ansible**:
  ```bash
  sudo apt update
  sudo apt install -y ansible
  ```

- **Конфигурация Ansible**:
  Создайте файл `inventory.ini` для хранения информации о серверах:
  ```ini
  [web]
  212.233.96.72 ansible_user=ubuntu ansible_ssh_pass=password ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'

  [db]
  212.233.98.71 ansible_user=ubunt ansible_ssh_pass=password ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  ```

- **Playbook для установки Nginx и MySQL**:
  Создайте файл `playbook.yml` со следующим содержимым:

  ```yaml
  - hosts: web
  become: yes
  tasks:
    - name: Update apt cache
      command: apt-get update
      changed_when: false

    - name: Pause for a moment to ensure apt cache is free
      wait_for:
        timeout: 10

    - name: Install Nginx
      command: apt-get install -y nginx
  
  - hosts: db
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
      changed_when: false

    - name: Pause to ensure apt cache is free
      wait_for:
        timeout: 15

    - name: Install MySQL
      apt:
        name: mysql-server
        state: present
  ```

- **Конфигурационный файл MySQL** (`mysql/mysqld.cnf`):
  
  ```ini
  [mysqld]
  bind-address = 0.0.0.0
  ```

#### VM2 (Веб-сервер с Nginx и PHP)

На VM2 разворачивается Nginx с поддержкой PHP для обработки запросов.

- **Конфигурационный файл Nginx** (`nginx/default`):
  
  ```nginx
  server {
      listen 80 default_server;
      listen [::]:80 default_server;

      root /var/www/html;
      index index.php index.html index.htm;

      server_name _;

      charset utf-8;

      location / {
          try_files $uri $uri/ =404;
      }

      location ~ \.php$ {
          include snippets/fastcgi-php.conf;
          fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
      }

      location ~ /\.ht {
          deny all;
      }
  }
  ```

- **Тестовый PHP-файл**:
  Создайте тестовый файл для проверки работы PHP: `/var/www/html/db_test.php`

  ```php
  <?php
  $servername = "212.233.98.71";  
  $username = "webuser";          
  $password = "password";         
  $dbname = "website_db";         

  $conn = new mysqli($servername, $username, $password, $dbname);

  if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
  }
  echo "Connected successfully";
  ?>
  ```

#### VM3 (Сервер базы данных MySQL)

На VM3 устанавливается и настраивается MySQL для удалённого доступа.

- **Создайте базу данных и пользователя**:

  ```sql
  CREATE DATABASE website_db;
  CREATE USER 'webuser'@'%' IDENTIFIED BY 'password';
  GRANT ALL PRIVILEGES ON website_db.* TO 'webuser'@'%';
  FLUSH PRIVILEGES;
  ```

# Результаты тестирования JMeter

Тестирование включало 1000 HTTP-запросов, ошибок не было.

## Резюме теста

- **Общее количество запросов**: 1000
- **Количество ошибок**: 0
- **Процент ошибок**: 0.0%
- **Пропускная способность**: 562.43 транзакции в секунду
- **Полученные данные**: 193.88 КБ/сек
- **Отправленные данные**: 63.16 КБ/сек

## Заключение

Результаты тестирования показывают, что система работает стабильно, без ошибок и с высокой пропускной способностью.
