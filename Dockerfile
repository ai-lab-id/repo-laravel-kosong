# ===============================
# Stage 1: Frontend build
# ===============================
FROM node:20-alpine AS frontend

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY resources ./resources
COPY vite.config.js postcss.config.js tailwind.config.js ./
RUN npm run build

# ===============================
# Stage 2: PHP runtime
# ===============================
FROM php:8.3-fpm

WORKDIR /var/www/html

# PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Copy Laravel app
COPY . .

# Copy Vite build result
COPY --from=frontend /app/public/build public/build

# Permission
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]
