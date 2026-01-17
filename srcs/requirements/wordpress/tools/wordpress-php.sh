#!/bin/bash

#set -e

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp-cli

mkdir -p /var/www/html && cd /var/www/html && mkdir -p /run/php

# php /var/www/html/wp-cli.phar  core download --allow-root
# php /var/www/html/wp-cli.phar  config create --dbname=wordpress --dbuser=wpuser --dbpass=password --dbhost=mariadb --allow-root
# php /var/www/html/wp-cli.phar  core install --url=localhost --title=inception --admin_user=admin --admin_password=admin --admin_email=admin@admin.com --allow-root



# MADANI_USER=madanidb
# MADANI_PASSWORD=madani_password
# MADANI_DATABASE=madani_db

wp-cli core download --allow-root
wp-cli config create --dbname=$MADANI_DATABASE \
							--dbuser=$MADANI_USER \
							--dbpass=$MADANI_PASSWORD \
							--dbhost=mariadb:3306 


# finally launch it
exec /usr/sbin/php-fpm7.4 -F