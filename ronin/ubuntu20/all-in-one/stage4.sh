#!/bin/bash
echo "Begin stage 4"

#Install apache and set running on non-standard ports (used for lua dynamic connections to services)
sudo mkdir -p /usr/sbin/
(
cat <<'EOF'
#!/bin/sh
exit 101
EOF
) | sudo tee /usr/sbin/policy-rc.d
sudo chmod 755 /usr/sbin/policy-rc.d
sudo apt-get install -y apache2
\rm 000-default-conf.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/000-default-conf.template
sudo /bin/cp 000-default-conf.template /etc/apache2/sites-available/000-default.conf
\rm ports.conf.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/ports.conf.template
sudo /bin/cp ports.conf.template /etc/apache2/ports.conf
sudo rm -f /usr/sbin/policy-rc.d
sudo systemctl start apache2

#Add features for auth pages

# o allow www-data to su
(
cat <<'EOFA'
www-data ALL=(ALL) NOPASSWD:ALL
EOFA
) | sudo tee /etc/sudoers.d/91-www-data-users

# o add address for auth.localhost
auth_etc=`grep 'auth\.localhost' /etc/hosts | wc -l`
if [ ${auth_etc} -eq "0" ]; then
(
cat <<'EOFA'
#added by SCITC provisioning
127.0.0.1 auth.localhost
EOFA
) | sudo tee -a /etc/hosts
fi

# o add nginx server record for auth.localhost
auth_sites=`grep 'server_name *auth\.localhost' /etc/nginx/sites-available/default-http | wc -l`
if [ ${auth_sites} -eq "0" ]; then
(
cat <<'EOFA'
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
) | sudo tee -a /etc/nginx/sites-available/default-http
fi


echo "End stage 4"
