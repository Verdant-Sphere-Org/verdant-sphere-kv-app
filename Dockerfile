FROM php:8.2-fpm as build
# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    supervisor \
    nginx \
    build-essential \
    openssl

RUN docker-php-ext-install gd pdo pdo_mysql sockets

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . /app
RUN composer install

FROM php:8.3.9RC1-fpm-alpine

COPY --from=build /app/app .

COPY --from=build /app/bootstrap .

COPY --from=build /app/config .

COPY --from=build /app/database .

COPY --from=build /app/logs .

COPY --from=build /app/public .

COPY --from=build /app/resources .

COPY --from=build /app/routes .

COPY --from=build /app/storage .

COPY --from=build /app/tests .

COPY --from=build /app/vendor .

COPY --from=build /app/app .

CMD php artisan serve --host=0.0.0.0 --port=8181
EXPOSE 8181