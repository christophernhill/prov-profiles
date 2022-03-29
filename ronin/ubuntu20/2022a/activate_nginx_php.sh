#!/bin/bash
( cd /etc/nginx/sites-available
  cp default /tmp/default.s00
  patch < /home/ubuntu/nginx_config_patch_01.diff
  cp default /tmp/default.s01
)
systemctl restart nginx
