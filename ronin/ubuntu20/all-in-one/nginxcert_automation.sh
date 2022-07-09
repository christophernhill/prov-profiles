#!/bin/bash

# this script is currently run at every boot time by the crontab command
# @reboot sh /home/ubuntu/nginxcert_automation.sh

echo "Starting:" > automation_stats.txt
date >> automation_stats.txt

echo > install_log.txt

\rm stage1.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/stage1.sh
chmod +x stage1.sh
./stage1.sh >> install_log.txt 2>&1

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

#Get and store machine name and user
MACHINE_NAME=`curl http://169.254.169.254/latest/meta-data/tags/instance/dns`
MACHINE_DOMAIN="mitresearch.cloud"
MACHINE_USER=`curl http://169.254.169.254/latest/meta-data/tags/instance/created_by | sed s/'.*:\(.*\)/\1/'`

#Let's Encrypt installation
#Install Certbot.
echo y | sudo apt install certbot python3-certbot-nginx 
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
echo y | sudo apt install php7.4-fpm
echo y | sudo apt install php7.4-cli
echo y | sudo apt install php7.4-mysql
echo y | sudo apt install php7.4-json
echo y | sudo apt install php7.4-curl
echo y | sudo apt install awscli
echo y | sudo apt install jq


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

sudo mkdir -p /home/root
echo $MACHINE_USER | sudo tee /home/root/auth_eppn_ids.txt

#Add conda and jupyterlab base (some to be replaced by modules)
if [ ! -d /home/ubuntu/miniconda3 ]; then
  \rm -fr Miniconda3-py39_4.10.3-Linux-x86_64.sh miniconda3
  \rm -fr environment.yml
  wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/environment.yml
  wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
  chmod +x Miniconda3-py39_4.10.3-Linux-x86_64.sh
  ./Miniconda3-py39_4.10.3-Linux-x86_64.sh -b -p miniconda3
  . miniconda3/bin/activate
  conda env create -f environment.yml
fi

#Install Jupyter lab service bits including helper scripts and setting env
\rm -fr get_free_port.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/get_free_port.sh
chmod +x get_free_port.sh

\rm -fr start_jupyter.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/start_jupyter.sh
chmod +x start_jupyter.sh

mkdir -p /home/ubuntu/.jupyter/
(
. /home/ubuntu/miniconda3/bin/activate mit-ronin-conda-2022a
env | grep -e '^CONDA_EXE' -e '^CONDA_PREFIX' -e '^CONDA_PROMPT_MODIFIER' -e '^PROJ_LIB' -e '^CONDA_PYTHON_EXE' -e '^CONDA_DEFAULT_ENV' -e '^PATH' > /home/ubuntu/.jupyter/env
)

(
cat <<'EOFA'
       # service name:     jupyter-lab.service 
       # path:             /lib/systemd/system/jupyter-lab.service

       [Unit]
       Description=Jupyter Lab Server

       [Service]
       Type=simple
       PIDFile=/run/jupyter-lab.pid

       EnvironmentFile=/home/ubuntu/.jupyter/env

       # Jupyter Notebook: change PATHs as needed for your system
       # ExecStart=/home/ubuntu/miniconda3/envs/mit-ronin-conda-2022a/bin/jupyter-lab --no-browser --ServerApp.token='' --ServerApp.password='' --ServerApp.ip='*'
       # ExecStart=/home/ubuntu/miniconda3/envs/mit-ronin-conda-2022a/bin/jupyter-lab --no-browser --ServerApp.token='' --ServerApp.password=''
       ExecStart=/home/ubuntu/start_jupyter.sh

       User=ubuntu
       Group=ubuntu
       WorkingDirectory=/home/ubuntu
       Restart=always
       RestartSec=10

       [Install]
       WantedBy=multi-user.target
EOFA
) | sudo tee /lib/systemd/system/jupyter-lab.service
sudo chmod 755 /lib/systemd/system/jupyter-lab.service
sudo systemctl enable jupyter-lab
sudo systemctl start  jupyter-lab


#Tweak nginx to allow longer names
ngin_hash_wc=`grep server_names_hash_bucket_size /etc/nginx/nginx.conf | grep 128 | wc -l`
if [ ${ngin_hash_wc} -eq "0" ]; then
cp /etc/nginx/nginx.conf .
ed nginx.conf <<'EOFA'
/server_names_hash_bucket_size
a
	server_names_hash_bucket_size 128;
.
w
q
EOFA
sudo cp nginx.conf /etc/nginx/nginx.conf
fi
sudo systemctl restart nginx

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


echo "Ending:" >> automation_stats.txt
date >> automation_stats.txt


