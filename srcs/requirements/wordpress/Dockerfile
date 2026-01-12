FROM debian:bullseye-slim

RUN apt-get update &&  \
    apt-get install -y curl  \
    php7.3 \
	php-fpm	\
    php-mysql mariadb-client

#COPY conf/www.conf /etc/php/7.3/fpm/pool.d/.

COPY tools/wordpress-php.sh .
RUN chmod +x wordpress-php.sh

CMD ["./wordpress-php.sh"]