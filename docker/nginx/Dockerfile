FROM nginx:alpine

WORKDIR /var/www/html

COPY --from=app /var/www/html /var/www/html
COPY default.conf /etc/nginx/conf.d/default.conf
