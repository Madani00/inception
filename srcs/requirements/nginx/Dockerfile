FROM debian:13

RUN apt-get update && apt-get upgrade && \
    apt-get install nginx openssl -y

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -out /etc/nginx/ssl/1337inception.crt -keyout /etc/nginx/ssl/1337inception.key 

CMD ["nginx", "-g", "daemon off;"]

