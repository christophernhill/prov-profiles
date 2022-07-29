#!/bin/bash
. /home/ubuntu/miniconda3/bin/activate
conda activate mit-ronin-conda-2022a
jupyter-lab list --jsonlist | jq '.[0] | .port '
