#!/bin/bash
#
#

ROOTDIR=.
cd ${ROOTDIR}

vb_and_vg_err=0
if [ "x$(which VirtualBox)" == "x" ]; then echo Virtual Box not found; vb_and_vg_err=1;  fi
if [ "x$(which vagrant)" == "x" ]; then echo Vagrant not found; vb_and_vg_err=1;  fi
if [ "x${vb_and_vg_err}" != "x0" ]; then 
  echo ERROR: missing requirements 
  exit
fi

WORK_DIR=$(basename `mktemp -u -t vgrnt`)
mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

mkdir vagrant
export MY_VAGRANT_SETUP_ROOT=`pwd`
export VAGRANT_HOME=${MY_VAGRANT_SETUP_ROOT}/.vagrant.d
export VAGRANT_DOTFILE_PATH=${MY_VAGRANT_SETUP_ROOT}/.vagrant

cd vagrant
cat >Vagrantfile <<'EOF'
Vagrant.configure("2") do |config|
  config.vm.box = "generic/rocky8"
  config.disksize.size = '500GB'
  config.vm.provider "virtualbox" do |vb|
      vb.memory = "8192"
      vb.cpus   = 4
  end
end
EOF

vagrant up
