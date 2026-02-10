FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y redis-server \
    && rm -rf /var/lib/apt/lists/*

RUN echo -e "maxmemory 256mb\nmaxmemory-policy allkeys-lfu" >> /etc/redis/redis.conf
RUN sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf

EXPOSE 6379

ENTRYPOINT [ "redis-server", "--protected-mode", "no" ]




