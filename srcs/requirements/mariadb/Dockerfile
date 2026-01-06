FROM debian:13

RUN apt-get update && apt-get upgrade && \
    apt-get install mariadb-server -y

COPY conf/50-server.conf	/etc/mysql/mariadb.conf.d/50-server.cnf

# RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY tools/mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb.sh

ENTRYPOINT ["mariadb.sh"]

