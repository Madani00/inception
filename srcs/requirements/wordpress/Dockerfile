FROM debian:bookworm-slim

RUN apt-get update &&  \
    apt-get install -y curl  \
    php8.2 \
	php8.2-fpm	\
    php8.2-mysql mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/.

COPY tools/wordpress-php.sh /usr/local/bin/ 
RUN chmod +x /usr/local/bin/wordpress-php.sh

EXPOSE 9000

ENTRYPOINT ["wordpress-php.sh"]