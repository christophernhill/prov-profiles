<?php
// Check PHP session varibales to see if logged in name is set
function is_logged_in()
{
    $retval = False;
    if ( isset($_SESSION['MY_PHP_AUTH_USER']) ) {
        $retval = True;
    }
    return $retval;
}
?>
