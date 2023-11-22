# Nginx + php-fpm (v8) + nodejs

Based on php:8.1.5-fpm-alpine3.15, node:18.1.0-alpine3.15 (nodejs is not included in most of other nginx-php images...but needed by a lot of php frameworks), with nginx:alpine and richarvey/nginx-php-fpm's Docker script

Tags:
* latest, php:8.2.12-fpm-alpine3.18

## PHP Modules

In this image it contains following PHP modules:

```
# php -m
[PHP Modules]
bcmath
Core
ctype
curl
date
dom
fileinfo
filter
ftp
gd
hash
iconv
igbinary
imap
intl
json
ldap
libxml
mbstring
memcached
msgpack
mysqli
mysqlnd
openssl
pcre
PDO
pdo_mysql
pdo_pgsql
pdo_sqlite
pgsql
Phar
posix
readline
redis
Reflection
session
SimpleXML
soap
sockets
sodium
SPL
sqlite3
standard
tokenizer
xml
xmlreader
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```

## How to use

For example, use this docker image to deploy a **Laravel 9** project.

### Develop with this image

Another example to develop with this image for a **Laravel 9** project, you may modify the `docker-compose.yml` of your project.

Make sure you have correct environment parameters set:

```yaml
# For more information: https://laravel.com/docs/sail
version: '3'
services:
  laravel:
    image: ghcr.io/setnemo/php:latest
    environment:
      WEBROOT: '/var/www/html/public'
      PHP_REDIS_SESSION_HOST: 'redis'
      CREATE_LARAVEL_STORAGE: '1'
      PHP_ERRORS_STDERR: '1'
      TZ: 'Europe/Kyiv'
    ports:
      - '${APP_PORT:-80}:80'
      - '${VITE_PORT:-5173}:5173'
    volumes:
      - '.:/var/www/html'
    networks:
      - sail
    depends_on:
      - postgres
      - redis
  postgres:
    image: postgres:9.5-alpine
    volumes:
      - "sail-postgres:/var/lib/postgresql/data"
    environment:
      - POSTGRES_USER=${DB_USERNAME}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_DATABASE}
    ports:
      - "${DB_PORT:-5432}:5432"
    networks:
      - sail
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 10s
      timeout: 5s
      retries: 5
  redis:
    image: 'redis:alpine'
    ports:
      - '${REDIS_PORT:-6379}:6379'
    volumes:
      - 'sail-redis:/data'
    networks:
      - sail
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      retries: 3
      timeout: 5s
  mailhog:
    image: 'mailhog/mailhog:latest'
    ports:
      - '${FORWARD_MAILHOG_PORT:-1025}:1025'
      - '${FORWARD_MAILHOG_DASHBOARD_PORT:-8025}:8025'
    networks:
      - sail
networks:
  sail:
    driver: bridge
volumes:
  sail-postgres:
    driver: local
  sail-redis:
    driver: local

```
