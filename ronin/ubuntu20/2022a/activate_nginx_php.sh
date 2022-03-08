#!/bin/bash
( cd /etc/nginx/sites-available
  patch /home/ubunut/nginx_config_patch.txt 
)
systemctl restart nginx
