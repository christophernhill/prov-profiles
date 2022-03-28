<?php
session_start();

ob_start();
// phpinfo();
var_dump($_SESSION);
var_dump($_SERVER);
$info = ob_get_contents();
ob_end_clean();

$fp = fopen("/tmp/phpinfo.html", "w");
fwrite($fp, $info);
fclose($fp);

http_response_code(200);
die();
?>
