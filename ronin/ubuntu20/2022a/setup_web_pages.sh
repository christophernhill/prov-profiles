#!/bin/bash
. ./vm_settings.src

cp  /home/ubuntu/var/www/html/* /var/www/html
cat /home/ubuntu/var/www/html/index2.php | sed s/XXXXREPLACE_WITH_MACHINE_URI_HEREXXXX/${INST_URI}/ > /var/www/html/index2.php

( cd /home/ubuntu/var/www ; tar -cvf - php/ ) | ( cd /var/www ; tar -xvf - )

cat > /etc/sudoers.d/91-www-data-users <<!
www-data ALL=(ALL) NOPASSWD:ALL
!

cat >> /etc/hosts <<!
127.0.0.1 auth.localhost
!

usermod -a -G sudo www-data
systemctl restart nginx
