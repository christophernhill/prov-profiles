#!/bin/bash
#
#

ROOTDIR=.
cd ${ROOTDIR}

vb_and_vg_err=0
if [ "x$(which VirtualBox)" == "x" ]; then echo Virtual Box not found; vb_and_vg_err=1;  fi
if [ "x$(which vagrant)" == "x" ]; then echo Vagrant not found; vb_and_vg_err=1;  fi
if [ "x${vb_and_vg_err}" != "x0"]; then echo ERROR: missing 

WORKD_DIR=`mktemp -d -t . _vgrnt `
cd ${WORK_DIR}


