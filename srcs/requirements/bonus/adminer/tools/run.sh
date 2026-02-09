mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
wget https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1.php -O /var/www/html/index.php