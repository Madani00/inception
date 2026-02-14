#!/bin/bash

set -e

mkdir -p /var/run/vsftpd/empty

if ! id "${INCEPTION_FTP_USER}" &>/dev/null; then
    useradd -m -d /home/${INCEPTION_FTP_USER} "${INCEPTION_FTP_USER}"
    echo "${INCEPTION_FTP_USER}:${INCEPTION_FTP_PASSWORD}" | chpasswd
fi

chown -R ${INCEPTION_FTP_USER}:${INCEPTION_FTP_USER} /var/www/html

exec /usr/sbin/vsftpd /etc/vsftpd.conf