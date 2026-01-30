FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    nginx \
    git unzip libzip-dev libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring zip fileinfo

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader \
 && chown -R www-data:www-data storage bootstrap/cache

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD service nginx start && php-fpm
