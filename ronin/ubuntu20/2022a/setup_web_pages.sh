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

cat >> /etc/nginx/sites-available/default <<'EOFA'

server {
    server_name auth.localhost;
    root /var/www/html/;

    access_log /var/log/nginx/auth.localhost.access.log;
    error_log /var/log/nginx/auth.localhost.error.log;

    index auth_index.php;

        location / {
          try_files $uri $uri/ /auth_index.php?$args;
        }


        # pass PHP scripts to FastCGI server
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
        #
        #       # With php-fpm (or other unix sockets):
                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        #       # With php-cgi (or other tcp sockets):
        #       fastcgi_pass 127.0.0.1:9000;
        }

}

EOFA

mkdir /var/www/html/private
touch /var/www/html/private/index.html

usermod -a -G sudo www-data
systemctl restart nginx
