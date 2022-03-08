#!/bin/bash
( cd /etc/nginx/sites-available
  patch < /home/ubuntu/nginx_config_patch.diff
)
systemctl restart nginx
