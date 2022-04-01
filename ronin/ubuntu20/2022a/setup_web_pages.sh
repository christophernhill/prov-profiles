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

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        }

}

EOFA

mkdir /var/www/html/private
touch /var/www/html/private/index.html

cat > /var/www/html/private/jupyter.php <<'EOFA'
<?php
echo 'hello from jupyter';
?>

EOFA

cat > /var/www/html/private/desktop.php <<'EOFA'
<?php
echo 'hello from desktop';
?>

EOFA



usermod -a -G sudo www-data
systemctl restart nginx

# Add apache on a different port for dynamic proxy via lua
apt install -y apache2
# Fix up config
( cd /home/ubuntu/prov-profiles/ronin/ubuntu20/2022a; cp etc/apache/ports.conf /etc/apache2/ports.conf )
( cd /home/ubuntu ;
  mkdir apache2_lua ;
  cd /home/ubuntu/prov-profiles/ronin/ubuntu20/2022a;
  cp  apache2_lua/* /home/ubuntu/apache2_lua
)

( cd /etc/apache2/mods-enabled/
  ln -s ../mods-available/lua.load . 
  ln -s ../mods-available/proxy.load . 
  ln -s ../mods-available/proxy_wstunnel.load . 
  ln -s ../mods-available/proxy_uwsgi.load . 
  ln -s ../mods-available/proxy_scgi.load . 
  ln -s ../mods-available/proxy_http2.load . 
  ln -s ../mods-available/proxy_http.load . 
  ln -s ../mods-available/proxy_html.load . 
  ln -s ../mods-available/proxy_hcheck.load . 
  ln -s ../mods-available/proxy_ftp.load . 
  ln -s ../mods-available/proxy_fdpass.load . 
  ln -s ../mods-available/proxy_fcgi.load . 
  ln -s ../mods-available/proxy_express.load . 
  ln -s ../mods-available/proxy_connect.load . 
  ln -s ../mods-available/proxy_balancer.load . 
  ln -s ../mods-available/proxy_ajp.load . 
  ln -s ../mods-available/xml2enc.load . 
  ln -s ../mods-available/slotmem_shm.load . 
)_
# Restart
systemctl restart apache2
