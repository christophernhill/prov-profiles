#!/bin/bash
#
# Commands for setting nginx so unrecognized https is error
#
#   - to execute remotely
#
#   IP_ADDRESS=35.87.120.96
#   SCRIPT_NAME=mk-defaulthttps.sh
#
#   scp -i ~/Downloads/.ssh/.ec2/aws-usw2-key2021 ${SCRIPT_NAME} ubuntu@${IP_ADDRESS}:
#   echo "chmod +x "${SCRIPT_NAME} | ssh -T -A -i ~/Downloads/.ssh/.ec2/aws-usw2-key2021  -l ubuntu ${IP_ADDRESS}
#   ssh -t -A -i ~/Downloads/.ssh/.ec2/aws-usw2-key2021  -l ubuntu ${IP_ADDRESS} sudo bash -c "./${SCRIPT_NAME}"

#

mkdir /etc/nginx/ssl/
openssl req -x509 -batch -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

cat >/etc/nginx/sites-available/default-https <<EOFA
server {
    server_name _;
    root /var/www/html/;

    access_log /var/log/nginx/default.access.log;
    error_log /var/log/nginx/default.error.log;

    listen 443 ssl;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        deny all;
    }
}
EOFA

ln -s /etc/nginx/sites-available/default-https /etc/nginx/sites-enabled/

systemctl reload nginx
