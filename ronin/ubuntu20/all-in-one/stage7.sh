#!/bin/bash
echo "Begin stage 7"

\rm setup_vnc_desktop.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/setup_vnc_desktop.sh
chmod +x setup_vnc_desktop.sh
./setup_vnc_desktop.sh

echo "End stage 7"
