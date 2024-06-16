FROM php:8.2-cli

COPY . .

RUN composer install

