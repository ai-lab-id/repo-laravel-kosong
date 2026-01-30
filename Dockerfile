# ===============================
# Stage 1: Frontend (Vite build)
# ===============================
FROM node:20-alpine AS frontend

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY resources ./resources
COPY vite.config.js postcss.config.js tailwind.config.js ./
RUN npm run build


# ===============================
# Stage 2: PHP Runtime
# ===============================
FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring zip fileinfo

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# copy vite build
COPY --from=frontend /app/public/build public/build

RUN composer install --no-dev --optimize-autoloader \
 && chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]
