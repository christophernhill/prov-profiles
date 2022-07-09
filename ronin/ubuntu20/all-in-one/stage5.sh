#!/bin/bash
echo "Begin stage 5"

mkdir apache2_lua

\rm logger.lua.template
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/logger.lua.template
cp logger.lua.template apache2_lua/logger.lua

echo "End stage 5"
