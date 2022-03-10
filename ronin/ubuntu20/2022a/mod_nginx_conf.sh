#!/bin/bash
( cd /etc/nginx
  patch < /home/ubuntu/nginx.conf-patch.diff
)
systemctl restart nginx
