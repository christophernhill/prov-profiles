<?php
// Need this in every file
session_start();
?>

<?php
phpinfo();
?>

<?php
if ( !isset($_SESSION['MY_PHP_AUTH_USER']) ) {
	echo 'Not logged in';
} else {
	echo 'Logged in as ' . $_SESSION['MY_PHP_AUTH_USER'];
  $_SESSION['RAND_STR_24']=bin2hex(random_bytes(24));
  echo 'Jupyter ' . 'http://localhost/jupyter/' . $_SESSION['RAND_STR_24']=bin2hex(random_bytes(24));
}
?>
