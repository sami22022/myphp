FROM php:8.3-fpm-alpine

# نصب وابستگی‌ها
RUN apk add --no-cache nginx supervisor curl

# ایجاد پوشه‌ها
RUN mkdir -p /var/www/html/api

# کپی فایل‌ها (با توجه به ساختار فعلی ریپازیتوری‌ات)
COPY api/sync.php /var/www/html/api/sync.php
COPY api/.htaccess /var/www/html/api/.htaccess

# تنظیم Nginx
COPY nginx.conf /etc/nginx/http.d/default.conf

# Supervisor
COPY supervisord.conf /etc/supervisord.conf

# مجوزها
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
