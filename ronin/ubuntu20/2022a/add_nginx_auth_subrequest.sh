#!/bin/bash
( cd /etc/nginx/sites-available
  patch < /home/ubuntu/nginx_config_patch_02.diff
)
systemctl restart nginx
