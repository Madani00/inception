FROM debian:bullseye-slim

RUN apt-get update &&  \
    apt-get install -y curl  \
    php7.4 \
	php7.4-fpm	\
    php7.4-mysql mariadb-client

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/.

COPY tools/wordpress-php.sh /usr/local/bin/ 
RUN chmod +x /usr/local/bin/wordpress-php.sh

ENTRYPOINT ["wordpress-php.sh"]