#!/bin/bash
fp=`/home/ubuntu/get_free_port.sh`
/home/ubuntu/miniconda3/envs/mit-ronin-conda-2022a/bin/jupyter-lab --no-browser --ServerApp.token='' --ServerApp.password='' --port=${fp} --ServerApp.base_url=jupyter/port_${fp} --ServerApp.allow_origin='*'
