#!/bin/bash

# set -e

# added so that we wait for the Mariadb database to be ready
# until mysql -h mariadb -u"$MADANI_USER" -p"$MADANI_PASSWORD" "$MADANI_DATABASE" -e "SELECT 1" >/dev/null 2>&1; do
#     echo "		Waiting for MariaDB to be READY"
#     sleep 2
# done

# Create the folder for the socket is required by php-fpm
mkdir -p /run/php

# Give the permissions to www-data user, group to access the folder
# this is good practice to avoid permission issues, php-fpm comes with its own www-data user and group. 
# that's why change the ownership of the folder
chown -R www-data:www-data /run/php

if [ -f /var/www/html/wp-config.php ]; then
	echo "WordPress is already installed."

else
	echo "Installing WordPress..."
# WordPress command line interface (WP-CLI) : provides useful commands and utilities to install, configure, and manage a WordPress site. 
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp-cli

	mkdir -p /var/www/html && cd /var/www/html

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

	# Create a new WordPress user.
	# wp-cli user create "$NEW_WP_USER" "$NEW_WP_USER_EMAIL" \
	# 					--user_pass="$NEW_WP_USER_PASSWORD" \
	# 					--role="author" \
	# 					--allow-root
	wp-cli user create "mehdi" "mehdi13@gmail.com" \
						--user_pass="mehdi12345" \
						--role="author" \
						--allow-root

fi	
# finally launch it
exec /usr/sbin/php-fpm7.4 -F