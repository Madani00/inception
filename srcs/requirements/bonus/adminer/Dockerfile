FROM debian:bookworm-slim

RUN apt-get update -y \
    && apt-get install -y wget php php-mysqli

COPY ./tools/run.sh .

RUN chmod +x run.sh && ./run.sh

EXPOSE 8080

ENTRYPOINT [ "php", "-S", "0.0.0.0:8080", "-t", "/var/www/html" ]

