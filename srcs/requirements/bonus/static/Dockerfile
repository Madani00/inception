FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install nginx -y \
    && rm -rf /var/lib/apt/lists/*

COPY conf/default.conf /etc/nginx/conf.d/default.conf

COPY portfolio/ /var/www/html/

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]


