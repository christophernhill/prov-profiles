<?php
// Need this in every file
session_start();
?>

<?php
// phpinfo();
?>

<?php
if ( !isset($_SESSION['MY_PHP_AUTH_USER']) ) {
	echo 'Not logged in';
} else {
	echo 'Logged in as ' . $_SESSION['MY_PHP_AUTH_USER'];
	if ( !array_key_exists('RAND_STR_24',$_SESSION) ) {
          $_SESSION['RAND_STR_24']=bin2hex(random_bytes(24));
	}
	echo '</br>';
        echo 'Jupyter ' . '<A href=/start_or_attach_to_jupyter_session.php>' . 'http://localhost/jupyter/' . $_SESSION['RAND_STR_24'] . '</A>';
}
?>

