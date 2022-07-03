#!/bin/bash

# this script is currently run at every boot time by the crontab command
# @reboot sh /home/ubuntu/nginxcert_automation.sh

#Link to AWS. 
curl http://10.0.1.106/add-http-https-access.php 

#Update local packages.
sudo apt update

#Nginx and php installation.
#Update local packages.
echo y | sudo apt install nginx

#Configure basic nginx with invalid cert ssl
if [ ! -d /etc/nginx/ssl/ ]; then
sudo mkdir /etc/nginx/ssl/
sudo openssl req -x509 -batch -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
sudo cat >/etc/nginx/sites-available/default-https-base <<EOFA
server {
    server_name _;
    root /var/www/html/;
    access_log /var/log/nginx/default.access.log;
    error_log /var/log/nginx/default.error.log;
    listen 443 ssl;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    index index.html;
        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files \$uri \$uri/ =404;
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
sudo /bin/rm /etc/nginx/sites-enabled/default-https
sudo /bin/rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/default-https-base /etc/nginx/sites-enabled/default-https
sudo ln -s /etc/nginx/sites-available/default-http       /etc/nginx/sites-enabled/default
fi
sudo systemctl reload nginx

#Enable ufw.
echo y | sudo ufw enable 
sudo ufw allow 'OpenSSH'
sudo ufw allow 'Nginx Full'
sudo ufw status

#Enable fail2ban with setup for ssh
echo y | sudo apt install fail2ban
(
sudo cat <<!
        [sshd]
        enabled = true
        mode    = aggressive
!
) | sudo tee /etc/fail2ban/jail.d/defaults-debian.conf > /dev/null
sudo chmod 0644 /etc/fail2ban/jail.d/defaults-debian.conf 

#Start nginx web server.
sudo systemctl start nginx 

#Get and store machine name.
MACHINE_NAME=`curl http://169.254.169.254/latest/meta-data/tags/instance/dns`

#Let's Encrypt installation
#Install Certbot.
echo y | sudo apt install certbot python3-certbot-nginx 
sudo systemctl reload nginx

#Get and register certificate.
# do this is cert is not yet valid
# otherwise skip so as not to get rate limit paused by Letsencrypt.
nrec_ssl=`curl https://${MACHINE_NAME}.mitresearch.cloud -vI --stderr - | grep '^*  SSL certificate verify ok.' | wc -l`
if [ $nrec_ssl -ne "1" ]; then
sudo certbot --nginx --noninteractive --agree-tos --cert-name ${MACHINE_NAME}.mitresearch.cloud -d ${MACHINE_NAME}.mitresearch.cloud --register-unsafely-without-email --nginx --redirect
sudo systemctl reload nginx
fi

#Test for Website.
curl https://${MACHINE_NAME}.mitresearch.cloud

#Add stage 0 index and .php
echo y | sudo apt install php7.4
echo y | sudo apt install php7.4-fpm
echo y | sudo apt install php7.4-cli
echo y | sudo apt install php7.4-mysql
echo y | sudo apt install php7.4-json
echo y | sudo apt install php7.4-curl
echo y | sudo apt install awscli
echo y | sudo apt install jq


