FROM debian:bookworm-slim

RUN apt-get update && apt-get install mariadb-server -y

COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY tools/mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb.sh 

EXPOSE 3306

ENTRYPOINT ["mariadb.sh"]


