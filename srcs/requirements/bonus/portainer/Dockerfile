FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/portainer/portainer/releases/download/2.21.5/portainer-2.21.5-linux-amd64.tar.gz -o portainer.tar.gz \
    && tar -xvf portainer.tar.gz \
    && rm portainer.tar.gz

EXPOSE 9443

ENTRYPOINT ["/portainer/portainer"]

