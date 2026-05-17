FROM php:8.3-fpm-alpine

RUN apk add --no-cache nginx curl

# ایجاد پوشه‌ها
RUN mkdir -p /var/www/html/api /var/run/php /var/lib/nginx/tmp

# کپی فایل‌ها
COPY api/sync.php /var/www/html/api/sync.php
COPY api/.htaccess /var/www/html/api/.htaccess
COPY nginx.conf /etc/nginx/http.d/default.conf

# تنظیم مجوزها
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# اجرای همزمان php-fpm و nginx
CMD sh -c "php-fpm8.3 -D && nginx -g 'daemon off;'"
