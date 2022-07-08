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
(
sudo cat <<'EOFA'
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	# SSL configuration
	#
	# listen 443 ssl default_server;
	# listen [::]:443 ssl default_server;
	#
	# Note: You should disable gzip for SSL traffic.
	# See: https://bugs.debian.org/773332
	#
	# Read up on ssl_ciphers to ensure a secure configuration.
	# See: https://bugs.debian.org/765782
	#
	# Self signed certs generated by the ssl-cert package
	# Don't use them in a production server!
	#
	# include snippets/snakeoil.conf;

	root /var/www/html;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ =404;
	}

	# pass PHP scripts to FastCGI server
	#
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
	#
	#	# With php-fpm (or other unix sockets):
		fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
	#	# With php-cgi (or other tcp sockets):
	#	fastcgi_pass 127.0.0.1:9000;
	}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}
}
EOFA
) | sudo tee /etc/nginx/sites-available/default-http > /dev/null

\rm nginx-default.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/nginx-default.template
sudo cp nginx-default.template /etc/nginx/sites-available/default-http

sudo /bin/rm /etc/nginx/sites-enabled/default-https
sudo /bin/rm /etc/nginx/sites-enabled/default
# sudo ln -s /etc/nginx/sites-available/default-https-base /etc/nginx/sites-enabled/default-https
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
sudo /binb/cp 000-default-conf.template /etc/apache2/sites-available/000-default.conf
sudo rm -f /usr/sbin/policy-rc.d
sudo systemctl start apache2

