FROM debian:bookworm-slim

RUN apt-get update -y \
    && apt-get install -y vsftpd ftp gettext-base

COPY conf/vsftpd.conf /etc/vsftpd.conf

COPY ./tools/run.sh .

RUN chmod +x run.sh


ENTRYPOINT [ "./run.sh" ]
