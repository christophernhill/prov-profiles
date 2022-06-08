#!/bin/bash
#Link to AWS. 
curl http://10.0.1.106/add-http-https-access.php 

#Update local packages.
sudo apt update

#Nginx installation.
#Update local packages.
echo y | sudo apt install nginx

#Enable ufw.
echo y | sudo ufw enable 
sudo ufw allow 'OpenSSH'
sudo ufw allow 'Nginx Full'
sudo ufw status

#Start nginx web server.
sudo systemctl start nginx 

#Get and store machine name.
MACHINE_NAME=`curl http://169.254.169.254/latest/meta-data/tags/instance/dns`

#Let's Encrypt installation
#Install Certbot.
echo y | sudo apt install certbot python3-certbot-nginx 
sudo systemctl reload nginx

#Get name of the machine in order to get the certificate.
#THIS IS WHERE THE PROBLEM IS 
sudo certbot --nginx --noninteractive --agree-tos --cert-name ${MACHINE_NAME}.mitresearch.cloud -d ${MACHINE_NAME}.mitresearch.cloud --register-unsafely-without-email --nginx --redirect
sudo systemctl reload nginx

#Test for Website.
curl https://${MACHINE_NAME}.mitresearch.cloud
