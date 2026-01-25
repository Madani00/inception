#!/bin/bash

set -e

# Check if MariaDB is already initialized
if [ ! -d "/var/lib/mysql/${MADANI_DATABASE}" ]; then
	
echo "First time initialization MariaDB..."

mysqld_safe &

sleep 5
	
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MADANI_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MADANI_USER}'@'%' IDENTIFIED BY '${MADANI_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MADANI_DATABASE}\`.* TO '${MADANI_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MADANI_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

mysqladmin -u root -p"${MADANI_ROOT_PASSWORD}" shutdown

fi


exec mysqld_safe




