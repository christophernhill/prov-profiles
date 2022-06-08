<?php
print 'Adding http and https ingress access for ';
print $_SERVER['REMOTE_ADDR'];
echo "\n";
$old_path=getcwd();
chdir('/home/ubuntu');
$output=shell_exec('./aws-ronin-add-http-https-to-instance.sh ' . $_SERVER['REMOTE_ADDR']);
print $output;
echo "\n";
chdir($old_path);
?>
