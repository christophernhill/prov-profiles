#!/bin/bash
#
# Create a basic Rocky 8 Vagrant + Virtual box VM with 8GB, 4 CPUS and 500GB root drive
#
# can be executed as
# $ curl -s https://raw.githubusercontent.com/christophernhill/prov-profiles/main/vagrant-local-example/stage1.sh | \
#   /bin/bash
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
vagrant plugin install vagrant-disksize
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

cat <<'EOF' | vagrant ssh
### Resizing with Rocky
sudo yum install -y e2fsprogs lvm2
sudo yum install cloud-utils-growpart gdisk -y
sudo growpart /dev/sda 2
sudo pvresize /dev/sda2
sudo lvextend -l +100%FREE /dev/mapper/rl_rocky8-root 
sudo xfs_growfs -d /dev/mapper/rl_rocky8-root
EOF

cat <<EOF > setup.sh
#!/bin/bash
#
# To use
# source ./setup.sh
#
export MY_VAGRANT_SETUP_ROOT=${MY_VAGRANT_SETUP_ROOT}
export VAGRANT_HOME=${MY_VAGRANT_SETUP_ROOT}/.vagrant.d
export VAGRANT_DOTFILE_PATH=${MY_VAGRANT_SETUP_ROOT}/.vagrant
EOF

cat <<EOF > clean.sh
#!/bin/bash
#
# To use
# ./clean.sh
#
source ./setup.sh
vagrant destroy
EOF



