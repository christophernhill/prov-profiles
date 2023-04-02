#!/bin/bash
#
# Add various core packages
#

. ./setup.sh

cat <<EOF > core-packages-install.src
sudo dnf -y install dnf-plugins-core

# - only do this if want latest kernel
# sudo dnf upgrade -y

sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf config-manager --set-enabled powertools

sudo yum -y install git
sudo yum -y install lua lua-filesystem lua-posix tcl
sudo yum -y install unzip
sudo yum -y install Lmod
sudo yum -y install gdbm-devel
sudo yum -y install zstd
sudo yum -y install bison bison-devel bison-runtime
sudo yum -y install gmp gmp-c++ gmp-devel


EOF
