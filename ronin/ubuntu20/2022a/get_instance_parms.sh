#!/bin/bash
#
# Get instance parameters
#
az=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`
iid=`curl http://169.254.169.254/latest/meta-data//instance-id`

iuri=${iid}.${az}.researchcomputing.cloud
