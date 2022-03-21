<?php
session_start();
setcookie(session_name(), '', 100);
unset( $_SESSION['MY_PHP_AUTH_USER'] );
session_unset();
session_destroy();
$_SESSION = array();
header("location: index.html");
exit();
?>
