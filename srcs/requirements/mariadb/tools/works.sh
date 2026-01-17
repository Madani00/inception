#!/bin/bash

# actual MariaDB daemon launcher that starts the database process directly
# The & puts it in the background, so the script continues
mysqld_safe &

# gives MariaDB time to fully initialize and create the socket file (very important)
sleep 5
# service mysql start <-- this one did not work inside the container


# Set root password (first time root has no password)
# mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MADANI_ROOT_PASSWORD}';" 2>/dev/null

# Now use root password for all commands
mysql -u root -p"${MADANI_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MADANI_DATABASE}\`;"
mysql -u root -p"${MADANI_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS \`${MADANI_USER}\`@'localhost' IDENTIFIED BY '${MADANI_PASSWORD}';"
mysql -u root -p"${MADANI_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS \`${MADANI_USER}\`@'%' IDENTIFIED BY '${MADANI_PASSWORD}';"
mysql -u root -p"${MADANI_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MADANI_DATABASE}\`.* TO \`${MADANI_USER}\`@'localhost' IDENTIFIED BY '${MADANI_PASSWORD}';"
mysql -u root -p"${MADANI_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MADANI_DATABASE}\`.* TO \`${MADANI_USER}\`@'%' IDENTIFIED BY '${MADANI_PASSWORD}';"
mysql -u root -p"${MADANI_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# Shutdown the temporary mariadb service 
mysqladmin -u root -p"${MADANI_ROOT_PASSWORD}" shutdown

# Start MariaDB in foreground
exec mysqld_safe



bind-address    = 0.0.0.0   # i guess this is the only thing that we change, all other things already default ones
port            = 3306 
max_connections = 10      # i only use wordpress







#!/bin/bash

set -e

mysqld_safe &

sleep 5


mysql -e "CREATE DATABASE IF NOT EXISTS \`${MADANI_DATABASE}\`;"
mysql -e "CREATE USER IF NOT EXISTS \`${MADANI_USER}\`@'localhost' IDENTIFIED BY '${MADANI_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${MADANI_DATABASE}\`.* TO \`${MADANI_USER}\`@'%' IDENTIFIED BY '${MADANI_PASSWORD}';"

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MADANI_ROOT_PASSWORD}';"

mysql -e "FLUSH PRIVILEGES;"


mysqladmin -u root -p"${MADANI_ROOT_PASSWORD}" shutdown


exec mysqld_safe

