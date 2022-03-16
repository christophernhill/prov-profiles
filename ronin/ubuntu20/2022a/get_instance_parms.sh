#!/bin/bash
#
# Get instance parameters
#
reg=`curl http://169.254.169.254/latest/meta-data/placement/region`
az=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`
iid=`curl http://169.254.169.254/latest/meta-data//instance-id`

iuri=${iid}.${az}.researchcomputing.cloud

echo > vm_settings.src
echo 'INST_ID='${iid}    >> vm_settings.src
echo 'INST_AZ='${az}     >> vm_settings.src
echo 'INST_REG='${reg}   >> vm_settings.src
echo 'INST_URI='${iuri}  >> vm_settings.src
