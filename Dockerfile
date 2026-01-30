# ===============================
# Stage 1: Build Vite assets
# ===============================
FROM node:20-alpine AS frontend

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY resources ./resources
COPY vite.config.js postcss.config.js tailwind.config.js ./

RUN npm run build

# ===============================
# Stage 2: PHP + Nginx
# ===============================
FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    nginx \
    git unzip libzip-dev libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring zip fileinfo

# REMOVE default nginx site
RUN rm -f /etc/nginx/sites-enabled/default

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# COPY VITE BUILD RESULT (INI KUNCI)
COPY --from=frontend /app/public/build public/build

RUN composer install --no-dev --optimize-autoloader \
 && chown -R www-data:www-data storage bootstrap/cache

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
