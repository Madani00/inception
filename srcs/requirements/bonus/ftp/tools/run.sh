#!/bin/bash

mkdir -p /var/run/vsftpd/empty

useradd -m -d /home/${INCEPTION_FTP_USER} "${INCEPTION_FTP_USER}"
echo "${INCEPTION_FTP_USER}:${INCEPTION_FTP_PASS}" | chpasswd
service vsftpd stop

/usr/sbin/vsftpd /etc/vsftpd.conf