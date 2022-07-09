#!/bin/bash

# this script is currently run at every boot time by the crontab command
# @reboot sh /home/ubuntu/nginxcert_automation.sh

echo "Starting:" > automation_stats.txt
date >> automation_stats.txt

echo > install_log.txt

#basic nginx
\rm stage1.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/stage1.sh
chmod +x stage1.sh
./stage1.sh >> install_log.txt 2>&1

#add lets encrytp nginx
\rm stage2.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/stage2.sh
chmod +x stage2.sh
./stage2.sh >> install_log.txt 2>&1

#add conda and jupyter lab service
\rm stage3.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/stage3.sh
chmod +x stage3.sh
./stage3.sh >> install_log.txt 2>&1

#add apache2
\rm stage4.sh
wget https://raw.githubusercontent.com/christophernhill/prov-profiles/main/ronin/ubuntu20/all-in-one/stage4.sh
chmod +x stage4.sh
./stage4.sh >> install_log.txt 2>&1

echo "Ending:" >> automation_stats.txt
date >> automation_stats.txt


