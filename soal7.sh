#!/bin/bash
apt update
apt install -y php8.4 php8.4-cli php8.4-fpm php8.4-mbstring php8.4-xml php8.4-curl php8.4-zip php8.4-sqlite3 php8.4-mysql nginx git unzip curl
curl -sS https://getcomposer.org/installer | php
cd .. /root
mv composer.phar /usr/local/bin/composer
cd /var/www
git clone https://github.com/elshiraphine/laravel-simple-rest-api laravel
cd laravel
composer config platform.php 8.2.0
composer update --no-scripts
composer install
cp .env.example .env
php artisan key:generate
chown -R www-data:www-data /var/www/laravel
chmod -R 755 /var/www/laravel
cat <<EOF > /etc/nginx/sites-available/laravel
server {
    listen 80;
    server_name <IP_WORKER>;

    root /var/www/laravel/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }

    access_log /var/log/nginx/laravel_access.log;
    error_log /var/log/nginx/laravel_error.log;
}

EOF

ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
nginx -t
service nginx restart
service php8.4-fpm restart
