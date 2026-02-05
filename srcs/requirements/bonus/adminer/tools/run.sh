mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /var/www/html/index.php