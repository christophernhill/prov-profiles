<?php
// Need this in every file
session_start();
include '/var/www/php/prov/functions.php';
?>

<?php
// Check logged in
if ( !is_logged_in() ) {
        $h_string='Location: index.html';
        header($h_string);
}
?>

<?php
echo 'Start Jupyter as ' . $_SESSION['MY_PHP_AUTH_USER'];
if ( !array_key_exists('RAND_STR_24',$_SESSION) ) {
    $_SESSION['RAND_STR_24']=bin2hex(random_bytes(24));
}
echo '</br>';
echo 'Jupyter ' . '<A href=/my_session_root.php>' . 'http://localhost/jupyter/' . $_SESSION['RAND_STR_24'] . '</A>';
?>
