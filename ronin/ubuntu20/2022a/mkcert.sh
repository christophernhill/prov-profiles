#!/bin/bash

#
# Commands for setting up letsencrypt in an automated way
#
#   IP_ADDRESS=35.87.120.96
#   SCRIPT_NAME=mk-certs.sh
#
#   scp -i ~/Downloads/.ssh/.ec2/aws-usw2-key2021 ${SCRIPT_NAME} ubuntu@${IP_ADDRESS}:
#   echo "chmod +x "${SCRIPT_NAME} | ssh -T -A -i ~/Downloads/.ssh/.ec2/aws-usw2-key2021  -l ubuntu ${IP_ADDRESS}
#   ssh -t -A -i ~/Downloads/.ssh/.ec2/aws-usw2-key2021  -l ubuntu ${IP_ADDRESS} sudo bash -c "./${SCRIPT_NAME}"

. /home/ubuntu/get_instance_parms.sh 


DNS_ZONE=${az}.researchcomputing.cloud
HTTPS_SERVER_NAMES=${iid}
IFS=","

for host in $HTTPS_SERVER_NAMES; do

 SERVER_HTTPS_NAME=${host}
 certbot --nginx --noninteractive --agree-tos --cert-name ${SERVER_HTTPS_NAME}.${DNS_ZONE} -d ${SERVER_HTTPS_NAME}.${DNS_ZONE}  --register-unsafely-without-email --nginx --redirect
 ## force renew case below (use after test)
 # certbot --force-renew --nginx --noninteractive --agree-tos --cert-name ${SERVER_HTTPS_NAME}.${DNS_ZONE} -d ${SERVER_HTTPS_NAME}.${DNS_ZONE}  --register-unsafely-without-email --nginx --redirect
 ## test case below use for checking things work without hitting rate limits
 # certbot --test-cert --nginx --noninteractive --agree-tos --cert-name ${SERVER_HTTPS_NAME}.${DNS_ZONE} -d ${SERVER_HTTPS_NAME}.${DNS_ZONE}  --register-unsafely-without-email --nginx --redirect

done

systemctl reload nginx
