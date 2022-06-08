#!/bin/bash
source setup
echo hi $1
ipaddr=$1

# Get instance id and its current security groups
iid=`aws ec2 describe-instances --filters Name=network-interface.addresses.private-ip-address,Values=${ipaddr} | grep InstanceId | awk '{print $2}' | tr -d '",'`
echo "Modifying instance id: "$iid

sgid0=`aws ec2 describe-instances --filters Name=network-interface.addresses.private-ip-address,Values=${ipaddr} | grep GroupId | awk '{print $2}' | sort | uniq | tr -d '",' | tr "\n" "," | sed s'/,$//' | tr "," " "`
echo "Current security groups: "$sgid0

# Get id for http and https public ingress security groups
# these have standard names ronin-http and ronin-https
aws ec2 describe-security-groups --filters Name=group-name,Values=ronin-http | grep GroupId
newgid1=`aws ec2 describe-security-groups --filters Name=group-name,Values=ronin-http  | grep GroupId | awk '{print $2}' | tr -d '",'`
newgid2=`aws ec2 describe-security-groups --filters Name=group-name,Values=ronin-https | grep GroupId | awk '{print $2}' | tr -d '",'`

aws ec2 modify-instance-attribute --instance-id ${iid} --groups ${sgid0} ${newgid1} ${newgid2}
aws ec2 modify-instance-metadata-options --instance-id ${iid} --instance-metadata-tags enabled
# aws ec2 modify-instance-metadata-options --instance-id ${iid} --instance-metadata-tags enabled
