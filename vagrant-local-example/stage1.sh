#!/bin/bash
#
#

ROOTDIR=.
cd ${ROOTDIR}

vb_and_vg_err=0
if [ "x$(which VirtualBox)" == "x" ]; then echo Virtual Box not found; vb_and_vg_err=1;  fi
if [ "x$(which vagrant)" == "x" ]; then echo Vagrant not found; vb_and_vg_err=1;  fi
if [ "x${vb_and_vg_err}" != "x0"]; then 
  echo ERROR: missing requirements 
  exit() 
fi

WORK_DIR=$(basename `mktemp -u -t vgrnt`)
mkdir -p ${WORK_DIR}
cd ${WORK_DIR}


