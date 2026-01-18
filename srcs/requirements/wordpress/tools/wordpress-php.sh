#!/bin/bash

#set -e

# WordPress command line interface (WP-CLI) : provides useful commands and utilities to install, configure, and manage a WordPress site. 
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp-cli

mkdir -p /var/www/html && cd /var/www/html

# Create the folder for the socket is required by php-fpm
mkdir -p /run/php

# Give the permissions to www-data user, group to access the folder
# this is good practice to avoid permission issues, php-fpm comes with its own www-data user and group. 
# that's why change the ownership of the folder
chown -R www-data:www-data /run/php

# php /var/www/html/wp-cli.phar  core download --allow-root
# php /var/www/html/wp-cli.phar  config create --dbname=wordpress --dbuser=wpuser --dbpass=password --dbhost=mariadb --allow-root
# php /var/www/html/wp-cli.phar  core install --url=localhost --title=inception --admin_user=admin --admin_password=admin --admin_email=admin@admin.com --allow-root




# Download the WordPress files.
wp-cli core download --allow-root

# Create the wp-config.php file with database connection details.
wp-cli config create --dbname=$MADANI_DATABASE \
							--dbuser=$MADANI_USER \
							--dbpass=$MADANI_PASSWORD \
							--dbhost=mariadb:3306 \
							--allow-root

# Install WordPress with site details.
wp-cli core install --url="localhost" \
					--title="Inception" \
					--admin_user="$MADANI_WP_ADMIN_USER" \
					--admin_password="$MADANI_WP_ADMIN_PASSWORD" \
					--admin_email="$MADANI_WP_ADMIN_EMAIL" \
					--allow-root

# finally launch it
exec /usr/sbin/php-fpm7.4 -F