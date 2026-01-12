#!/bin/bash

mysqld_safe &

sleep 5

MADANI_USER=madanidb
MADANI_PASSWORD=madani_password
MADANI_ROOT_PASSWORD=root_password  
MADANI_HOST=localhost
MADANI_DATABASE=madani_db


mysql -e "CREATE DATABASE IF NOT EXISTS \`${MADANI_DATABASE}\`;"
mysql -e "CREATE USER IF NOT EXISTS \`${MADANI_USER}\`@'localhost' IDENTIFIED BY '${MADANI_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${MADANI_DATABASE}\`.* TO \`${MADANI_USER}\`@'%' IDENTIFIED BY '${MADANI_PASSWORD}';"

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MADANI_ROOT_PASSWORD}';"

mysql -e "FLUSH PRIVILEGES;"


mysqladmin -u root -p"${MADANI_ROOT_PASSWORD}" shutdown


exec mysqld_safe



