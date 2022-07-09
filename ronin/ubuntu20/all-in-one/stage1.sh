#!/bin/bash
echo "Begin stage 1"

#Wait for cloud-init to finish
echo "Checking for cloud-init to finish"
i=0; 
while [ $i -le 3600 ]; do 
        cistat=`cloud-init status`; 
        echo $i" "$cistat
        if [ "${cistat}" = "status: done" ]; then 
                break; 
        fi      
        sleep 1; 
        i=$(( i+1 )) 
done    


#Link to AWS. 
curl http://10.0.1.106/add-http-https-access.php 

#Turn off automated upgrades
sudo systemctl disable unattended-upgrades.service
sudo systemctl stop unattended-upgrades.service

#Update local packages.
sudo apt-get -y update

#Nginx and php installation.
#Update local packages.
sudo apt-get -y install nginx

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

echo "End stage 1"
