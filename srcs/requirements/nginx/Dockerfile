FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install nginx openssl -y && \
    mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -out /etc/nginx/ssl/1337inception.crt -keyout /etc/nginx/ssl/1337inception.key \
    -subj "/CN=eamchart.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

#RUN chmod 755 /var/www/html
#RUN chown -R www-data:www-data /var/www/html

CMD ["nginx", "-g", "daemon off;"]

