FROM php:8.3-fpm-alpine

# نصب nginx و curl
RUN apk add --no-cache nginx curl

# ایجاد پوشه‌های مورد نیاز
RUN mkdir -p /var/www/html/api /var/run/php /var/lib/nginx/tmp /var/log/nginx

# کپی فایل‌های پروژه
COPY api/sync.php /var/www/html/api/sync.php
COPY api/.htaccess /var/www/html/api/.htaccess
COPY nginx.conf /etc/nginx/http.d/default.conf

# تنظیم مجوزها
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80

# اجرای nginx و php-fpm
CMD sh -c "php-fpm8.3 -D && nginx -g 'daemon off;'"
