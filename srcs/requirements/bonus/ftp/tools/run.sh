#!/bin/bash

set -e

mkdir -p /var/run/vsftpd/empty

useradd -m -d /home/${INCEPTION_FTP_USER} "${INCEPTION_FTP_USER}"
echo "${INCEPTION_FTP_USER}:${INCEPTION_FTP_PASSWORD}" | chpasswd

# useradd -m -d /var/www/html "${INCEPTION_FTP_USER}"
# echo "${INCEPTION_FTP_USER}:${INCEPTION_FTP_PASSWORD}" | chpasswd

exec /usr/sbin/vsftpd /etc/vsftpd.conf