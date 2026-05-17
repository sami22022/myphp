FROM php:8.3-fpm-alpine

RUN apk add --no-cache nginx curl

# ایجاد پوشه‌ها
RUN mkdir -p /var/www/html/api /var/run/php /var/lib/nginx/tmp

# کپی فایل‌های تونل
COPY api/sync.php /var/www/html/api/sync.php
COPY api/.htaccess /var/www/html/api/.htaccess

# تنظیم nginx با روش صحیح
RUN cat > /etc/nginx/http.d/default.conf << 'EOF'
server {
    listen 80 default_server;
    root /var/www/html;
    index index.php;

    location / {
        try_files $uri $uri/ =404;
    }

    location \~ \.php$ {
        fastcgi_pass unix:/var/run/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

# تنظیم مجوزها
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# اجرای همزمان php-fpm و nginx
CMD sh -c "php-fpm8.3 -D && nginx -g 'daemon off;'"
