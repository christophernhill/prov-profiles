#!/bin/bash
. ./vm_settings.src

cp  var/www/html/* /var/www/html
cat var/www/html/index2.php | sed s/XXXXREPLACE_WITH_MACHINE_URI_HEREXXXX/${INST_URI}/ > /var/www/html/index2.php
