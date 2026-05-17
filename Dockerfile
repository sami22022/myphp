FROM php:8.3-fpm-alpine

# نصب وابستگی‌ها
RUN apk add --no-cache nginx supervisor curl

# ایجاد پوشه‌ها
RUN mkdir -p /var/www/html/api

# کپی فایل‌ها
COPY api/sync.php /var/www/html/api/sync.php
COPY api/.htaccess /var/www/html/api/.htaccess
COPY nginx.conf /etc/nginx/http.d/default.conf
COPY supervisord.conf /etc/supervisord.conf

# نصب php socket و تنظیمات
RUN mkdir -p /var/run/php \
    && chown -R www-data:www-data /var/www/html /var/run/php \
    && chmod -R 755 /var/www/html

# مجوزهای nginx
RUN mkdir -p /var/lib/nginx/tmp/client_body \
    && chown -R nginx:nginx /var/lib/nginx

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
