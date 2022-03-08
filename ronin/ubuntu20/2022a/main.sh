#!/bin/bash
./conda_and_jlab.sh
./activate_nginx_php.sh 
. ./get_instance_parms.sh
echo ${iuri}
