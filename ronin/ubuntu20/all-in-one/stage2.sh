#!/bin/bash
echo "Begin stage 2"

#Enable ufw.
echo y | sudo ufw enable 
sudo ufw allow 'OpenSSH'
sudo ufw allow 'Nginx Full'
sudo ufw status

#Enable fail2ban with setup for ssh
sudo apt-get -y install fail2ban
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

#Get and store machine name and user
MACHINE_NAME=`curl http://169.254.169.254/latest/meta-data/tags/instance/dns`
MACHINE_DOMAIN="mitresearch.cloud"
MACHINE_USER=`curl http://169.254.169.254/latest/meta-data/tags/instance/created_by | sed s/'.*:\(.*\)/\1/'`

#Let's Encrypt installation
#Install Certbot.
sudo apt-get -y install certbot python3-certbot-nginx 
sudo systemctl reload nginx

#Get and register certificate.
# do this is cert is not yet valid
# otherwise skip so as not to get rate limit paused by Letsencrypt.
nrec_ssl=`curl https://${MACHINE_NAME}.${MACHINE_DOMAIN} -vI --stderr - | grep '^*  SSL certificate verify ok.' | wc -l`
if [ $nrec_ssl -ne "1" ]; then
sudo certbot --nginx --noninteractive --agree-tos --cert-name ${MACHINE_NAME}.${MACHINE_DOMAIN} -d ${MACHINE_NAME}.${MACHINE_DOMAIN} --register-unsafely-without-email --nginx --redirect
sudo systemctl reload nginx
fi

#Test for Website.
curl https://${MACHINE_NAME}.${MACHINE_DOMAIN}

#Add stage 0 index and .php
#echo y | sudo apt install php7.4
sudo apt-get -y install php7.4-fpm
sudo apt-get -y install php7.4-cli
sudo apt-get -y install php7.4-mysql
sudo apt-get -y install php7.4-json
sudo apt-get -y install php7.4-curl
sudo apt-get -y install awscli
sudo apt-get -y install jq


#Add test php page
(
sudo cat <<'EOFA'
<html>
 <head>
  <title>PHP Test</title>
 </head>
 <body>
 <?php echo '<p>Hello World from PHP</p>'; ?> 
 </body>
</html>
EOFA
) | sudo tee /var/www/html/test_php.php > /dev/null

#Add test php login page
(
sudo cat <<'EOFA'
<html>
 <head>
  <title>PHP Login Test</title>
 </head>
 <body>
 <?php echo '<p>Hello World from PHP login test</p>'; ?> 
 </body>
</html>
EOFA
) | sudo tee /var/www/html/test_login.php > /dev/null

#Make login setup
\rm fwd2login.php.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/fwd2login.php.template
cat fwd2login.php.template | sed s'/XXXXREPLACE_WITH_MACHINE_URI_HEREXXXX/'${MACHINE_NAME}.${MACHINE_DOMAIN}'/' | sudo tee /var/www/html/fwd2login.php

\rm login.php.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/login.php.template
sudo cp login.php.template /var/www/html/login.php

\rm index3.php.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/index3.php.template
sudo cp index3.php.template /var/www/html/index3.php

\rm auth_index.php.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/auth_index.php.template
sudo cp auth_index.php.template /var/www/html/auth_index.php

sudo mkdir -p /var/www/php/prov
\rm prov_functions.php.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/prov_functions.php.template
sudo cp prov_functions.php.template /var/www/php/prov/functions.php



sudo mkdir -p /home/root
echo $MACHINE_USER | sudo tee /home/root/auth_eppn_ids.txt

echo "End stage 2"
