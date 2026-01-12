#!/bin/bash

set -e

mkdir -p /var/www/html

cd /var/www/html

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

php /var/www/html/wp-cli.phar  core download --allow-root
php /var/www/html/wp-cli.phar  config create --dbname=wordpress --dbuser=wpuser --dbpass=password --dbhost=mariadb --allow-root
php /var/www/html/wp-cli.phar  core install --url=localhost --title=inception --admin_user=admin --admin_password=admin --admin_email=admin@admin.com --allow-root



# finally launch it
/usr/sbin/php-fpm7.3 -F