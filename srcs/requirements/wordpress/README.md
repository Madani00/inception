**conf/www.conf**
```Ini, TOML
[www]

user = www-data
group = www-data

; The address on which to accept FastCGI requests.
listen = 0.0.0.0:9000

pm = dynamic

pm.max_children = 5

pm.start_servers = 2

pm.min_spare_servers = 1

pm.max_spare_servers = 3

```
this configuration with `listen = 0.0.0.0:9000` should work fine, but using `listen = wordpress:9000` or even just `listen = 9000` would be more aligned with Docker best practices.

**wordpress-php.sh**
```bash
#!/bin/bash

# means if any command fails. script stop immediatelly
set -e

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

# Download the WordPress files.
wp-cli core download --allow-root

# Create the wp-config.php file with database connection details.
#wp-cli config create --dbname=$MADANI_DATABASE \
#							--dbuser=$MADANI_USER \
#							--dbpass=$MADANI_PASSWORD \
#							--dbhost=mariadb:3306 \
#							--allow-root

# Install WordPress with site details.
# wp-cli core install --url="localhost" \
#					--title="Inception" \
#					--admin_user="$MADANI_WP_ADMIN_USER" \
#					--admin_password="$MADANI_WP_ADMIN_PASSWORD" \
#					--admin_email="$MADANI_WP_ADMIN_EMAIL" \
#					--allow-root

# finally launch it
# -F: PHP-FPM starts, puts itself in the background (daemon off)
exec /usr/sbin/php-fpm7.4 -F
```

**Dockerfile**
```Dockerfile
FROM debian:bookworm-slim

RUN apt-get update &&  \
    apt-get install -y curl  \
    php8.2 \
	php8.2-fpm	\
    php8.2-mysql mariadb-client 

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/.

COPY tools/wordpress-php.sh .
RUN chmod +x wordpress-php.sh

CMD ["./wordpress-php.sh"]

```