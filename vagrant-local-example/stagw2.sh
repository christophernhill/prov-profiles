#!/bin/bash
#
# Add various core packages
#

. ./setup.sh

cat <<EOF > core-packages-install.src
sudo dnf -y install dnf-plugins-core
sudo dnf upgrade -y
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf config-manager --set-enabled powertools
EOF