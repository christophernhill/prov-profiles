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


echo "End stage 5"
