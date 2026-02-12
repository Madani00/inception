FROM debian:bookworm-slim

RUN apt-get update -y \
    && apt-get install -y vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf

COPY ./tools/run.sh .

RUN chmod +x run.sh


ENTRYPOINT [ "./run.sh" ]
