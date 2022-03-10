#!/bin/bash
( cd /etc/nginx
  patch < /home/ubuntu/nginx_config_patch.diff
)
systemctl restart nginx
