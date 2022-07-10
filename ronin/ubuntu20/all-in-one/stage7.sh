#!/bin/bash
echo "Begin stage 7"

# Add modules from SC, use NFS for now (later CVMFS ....)

sudo apt-get install -y environment-modules
sudo apt-get install -y nfs-common
sudo mkdir -p /state/partition1/llgrid/pkg
sudo mount -t nfs 10.0.1.87:/mnt/scmodules /state/partition1/llgrid/pkg
(
cd /etc/environment-modules;
sudo tar -xzvf /state/partition1/llgrid/pkg/em.tgz
)


echo "End stage 7"
