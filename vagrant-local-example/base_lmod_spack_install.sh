#!/bin/bash
#
#
# Base provisioning and create an LMOD setup using spack
# For some reason lmod itself is not well supported by yum, dnf, apt etc....
# Here we do a base install using a spack with a simple path and against system
# stack. This can then been used for downstream installs. 
#

source ./setup.sh
