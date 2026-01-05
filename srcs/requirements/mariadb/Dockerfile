FROM debian:13

RUN apt-get update && apt-get upgrade && \
    apt-get install mariadb-server -y

COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf

ENTRYPOINT ["mariadb.sh"]

