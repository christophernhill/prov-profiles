#!/bin/bash
# ( cd /etc/nginx/sites-available
#  patch < /home/ubuntu/nginx_config_patch_02.diff
# )

cat >/etc/nginx/sites-available/default <<'EOFA'
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;

	server_name _;

  # These are pre-auth, so need to skip auth.
	location / {
		try_files $uri $uri/ =404;
	}
  location = /index2.php {
		include snippets/fastcgi-php.conf;
		fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
  }
  location = /index3.php {
		include snippets/fastcgi-php.conf;
		fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
  }

  # Below here will go through auth/
	location ~ \.php$ {
    auth_request /auth;
		include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
	}
  location /private {
    auth_request /auth;
    try_files $uri $uri/ /auth_index.php?$args;
  }
  location = /auth {
    internal;
    proxy_pass  http://auth.localhost;
    proxy_pass_request_body off;
    proxy_set_header Content-Length "";
    proxy_set_header X-Original-URI $request_uri;
  }
  error_page 401 = @login;
  location @login {
    return 302 https://$host/index.html;
  }
}
EOFA

systemctl restart nginx
