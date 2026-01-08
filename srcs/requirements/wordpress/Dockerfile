FROM debian:bullseye-slim

RUN apt-get update &&  \
    apt-get install -y wget  \
    php7.3 \
	php-fpm	\
    php-mysql mariadb-client

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    wp-cli.phar /usr/local/bin/wp




ENTRYPOINT ["mariadb.sh"]