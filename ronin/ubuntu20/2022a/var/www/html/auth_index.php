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

// Lets try forwarding to login page if no MY_PHP_USER variable in session
// $_SESSION['MY_PHP_AUTH_USER']
if ( !array_key_exists('MY_PHP_AUTH_USER',$_SESSION) ) {
	// header("location: index.html");
        http_response_code(401);
        die();
}

http_response_code(200);
die();
?>
