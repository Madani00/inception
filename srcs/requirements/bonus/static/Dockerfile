FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install nginx -y \
    && rm -rf /var/lib/apt/lists/*


# COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# COPY portfolio/index.html /var/www/html/index.html
# Copy HTML/CSS/JS files to the appropriate location
# COPY portfolio/ /usr/share/nginx/html/portfolio/
COPY portfolio/ /var/www/html/

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]


