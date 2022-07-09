#!/bin/bash
echo "Begin stage 5"

mkdir apache2_lua

\rm logger.lua.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/logger.lua.template
cp logger.lua.template apache2_lua/logger.lua

\rm node_proxy.lua.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/node_proxy.lua.template
cp node_proxy.lua.template apache2_lua/node_proxy.lua

\rm proxy.lua.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/proxy.lua.template
cp proxy.lua.template apache2_lua/proxy.lua

\rm apache2.conf.append.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/apache2.conf.append.template
apconf_lua=`grep '/home/ubuntu/apache2_lua' /etc/apache2/apache2.conf | wc -l`
if [ ${apconf_lua} -eq "0" ]; then
cat apache2.conf.append.template | sudo tee -a /etc/apache2/apache2.conf
fi
sudo systemctl restart apache2

sudo usermod -a -G sudo www-data
sudo systemctl restart nginx

( cd /etc/apache2/mods-enabled/
  sudo ln -s ../mods-available/lua.load . 
  sudo ln -s ../mods-available/proxy.load . 
  sudo ln -s ../mods-available/proxy_wstunnel.load . 
  sudo ln -s ../mods-available/proxy_uwsgi.load . 
  sudo ln -s ../mods-available/proxy_scgi.load . 
  sudo ln -s ../mods-available/proxy_http2.load . 
  sudo ln -s ../mods-available/proxy_http.load . 
  sudo ln -s ../mods-available/proxy_html.load . 
  sudo ln -s ../mods-available/proxy_hcheck.load . 
  sudo ln -s ../mods-available/proxy_ftp.load . 
  sudo ln -s ../mods-available/proxy_fdpass.load . 
  sudo ln -s ../mods-available/proxy_fcgi.load . 
  sudo ln -s ../mods-available/proxy_express.load . 
  sudo ln -s ../mods-available/proxy_connect.load . 
  sudo ln -s ../mods-available/proxy_balancer.load . 
  sudo ln -s ../mods-available/proxy_ajp.load . 
  sudo ln -s ../mods-available/xml2enc.load . 
  sudo ln -s ../mods-available/slotmem_shm.load . 
)
sudo systemctl restart apache2



echo "End stage 5"
