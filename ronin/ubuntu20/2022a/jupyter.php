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

// su -l ubuntu /bin/bash -c /home/ubuntu/get_current_jupyter_lab_port.sh
$output = shell_exec("(sudo su -l ubuntu /bin/bash -c /home/ubuntu/get_current_jupyter_lab_port.sh ) 2>&1");
$output = trim($output);
if ( is_numeric($output) ) {
  $host=$_SERVER['SERVER_NAME'];
  $fwpath="/jupyter/port_" . $output . "/lab?";
  echo '</br>';
  $fw2="https://" . $host . $fwpath;
  header("Location: " . $fw2);
  exit();
} else {
 echo '</br>';
 echo $output;
 echo '</br>';
 echo gettype($output);
 echo '</br>';
 echo "Hmmmmm";
}

?>
