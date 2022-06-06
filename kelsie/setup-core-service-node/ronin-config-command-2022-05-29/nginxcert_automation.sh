#!/bin/bash

#Update local packages.
sudo apt update

#Run line of code that Mr.Chris told me to add.
curl http://10.0.1.106/add-http-https-access.php 

#Nginx installation
#Update local packages.
sudo apt install nginx
nginx -v
echo "Message: System updated and nginx installed."

#Enable ufw.
sudo ufw enable
sudo ufw allow 'OpenSSH'
sudo ufw allow 'Nginx Full'
sudo ufw status
echo "Message: Firewall enabled and configured."

#Overwrite default file.
echo allow_https_traffic.txt > /etc/nginx/sites-enabled/default

#Start nginx web server.
sudo systemctl reload nginx
sudo systemctl start nginx 
systemctl status nginx &
echo "Message: Web server is up and running."

#Let's Encrypt installation
#Install Certbot.
sudo apt install certbot python3-certbot-nginx
sudo systemctl reload nginx
echo "Message: Cerbot installed and nginx reloaded."

#Get name of the machine in order to get the certificate.
MACHINE_NAME=`curl http://169.254.169.254/latest/meta-data/tags/instance/dns`
sudo certbot --nginx --noninteractive --agree-tos --cert-name ${MACHINE_NAME}.mitresearch.cloud -d ${MACHINE_NAME}.mitresearch.cloud --register-unsafely-without-email --nginx --redirect
sudo systemctl reload nginx
echo "Message: Certificate issued and nginx reloaded."
