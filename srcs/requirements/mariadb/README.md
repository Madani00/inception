**conf/50-server.cnf**
```Ini, TOML
[mysqld]

user = mysql
datadir = /var/lib/mysql
socket = /run/mysqld/mysqld.sock
bind-address = 0.0.0.0
port = 3306 
```
`bind-address` is the only thing we changed, all other things already default ones, By default, MariaDB sets this to `127.0.0.1`, which means "Only accept connections from inside this container. Since WordPress is in a *different* container, it is coming from the "outside." Setting this to `0.0.0.0`  tells MariaDB to accept connections from **any IP address** on the network. or for better set up you can change it to `mariadb`

**tools/mariadb.sh**
```bash
#!/bin/bash

# actual MariaDB daemon launcher that starts the database process directly
# The & puts it in the background, so the script continues
mysqld_safe &  #  or mariadbd-safe &

# gives MariaDB time to fully initialize and create the socket file (very important)
sleep 5

# Set root password with ALTER command (first time root has no password)
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MADANI_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MADANI_USER}'@'%' IDENTIFIED BY '${MADANI_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MADANI_DATABASE}\`.* TO '${MADANI_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MADANI_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

# Shutdown the temporary mariadb service 
mysqladmin -u root -p"${MADANI_ROOT_PASSWORD}" shutdown

# Start MariaDB again in foreground
exec mysqld_safe
```

**Dockerfile**
```Dockerfile
FROM debian:bookworm-slim

RUN apt-get update && apt-get install mariadb-server -y

COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf

# Create the folder for the socket
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY tools/mariadb.sh .
RUN chmod +x mariadb.sh

ENTRYPOINT ["./mariadb.sh"]
```
- [ ] creating this `/run/mysqld` in necessary, if doesn't exist or isn't, MariaDB will crash immediately.```
> ⚠️ subject said:  the containers must be built either from the penultimate stable which means the version before the current stable one.
that's why i picked `debian:bookworm-slim`