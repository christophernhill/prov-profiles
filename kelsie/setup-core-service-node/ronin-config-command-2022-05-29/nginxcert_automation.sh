#!/bin/bash

#Update local packages.
sudo apt update
sudo apt upgrade

#Run line of code that Mr.Chris told me to add.
curl http://10.0.1.106/add-http-https-access.php > add-http-https-access.sh
chmod +x add-http-https-access.sh
./add-http-https-access.sh

#Nginx installation
#Update local packages.
sudo apt install nginx
echo "System updated and nginx installed."

#Enable ufw.
sudo ufw enable
sudo ufw allow 'OpenSSH'
sudo ufw allow 'Nginx Full'
sudo ufw status
echo "Firewall enabled and configured."

#Start nginx web server.
sudo systemctl reload nginx 
systemctl status nginx &
echo "Web server is up and running."

#Let's Encrypt installation
#Install Certbot.
sudo apt install certbot python3-certbot-nginx
sudo systemctl reload nginx
echo "Cerbot installed and nginx reloaded."

#Get name of the machine in order to get the certificate.
MACHINE_NAME=`curl http://169.254.169.254/latest/meta-data/tags/instance/dns`
sudo certbot --nginx --noninteractive --agree-tos --cert-name ${MACHINE_NAME}.mitresearch.cloud -d ${MACHINE_NAME}.mitresearch.cloud --register-unsafely-without-email --nginx --redirect
sudo systemctl reload nginx
echo "Certificate issued and nginx reloaded."

#Enable Auto-renewal (???)
