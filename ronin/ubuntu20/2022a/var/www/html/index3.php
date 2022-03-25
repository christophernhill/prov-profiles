<?php

session_start();
$sess_path=session_save_path();
print 'Session path = ' . $sess_path;
print '</br>';
$tfile_plain=tmpfile();
print 'Plain text file = ' . $tfile_plain;
print '</br>';
$tfile_crypt=tmpfile();
print 'Encrypted text file = ' . $tfile_crypt;
print '</br>';

// Debugging
ini_set('display_errors',1);
error_reporting(E_ALL);

//
// SSL keys and certs load
var_dump(openssl_get_cert_locations());
print '</br>';

// Print session id
print "session id = ";
print session_id();
print '</br>';

// Extract user id, session key and timestamp.
//
// user id will be encrypted by trusted, secure system ( for example researchcomputng.mit.edu ) to ensure
// it is tied to an authenticated session that was authenticated by the secure system.
// session key is also encrypted the same way. It is the key from the app server original connection and should 
// match the session key tied to this page. Checking it is another check for any malicious spoofing. 
// The timestamp is used to ensure this is a recent sign on since the verification is automated any delays are
// not expected.
$ruri=parse_url($_SERVER['REQUEST_URI']);
$rquery=urldecode($ruri["query"]);
var_dump($rquery);print "</br>";
$results="";
$nmatch=preg_match("/eppn=([^ ]*) (.*)/",$rquery,$results);
var_dump($results); print "</br>";
print($nmatch); print "</br>";
if ( $nmatch == 1 ) {
	$ueppn=$results[1];
	$tcode=$results[2];
} else {
	print("Error: Unexpected eppn"); print "</br>";
	exit();
}

$tz=new DateTimeZone("UTC");
$date = new DateTime("now",$tz);
$dts=$date->getTimestamp();
if ( abs(($dts - intval($tcode))) > 5 ) {
	print("Error: timestamp skew too big"); print "</br>";
	exit();
}

$auth_eppn_list=file("/home/root/auth_eppn_ids.txt", FILE_IGNORE_NEW_LINES);
var_dump($auth_eppn_list);print "</br>";

$ueppn_match=in_array($ueppn,$auth_eppn_list,true);
if ( $ueppn_match ) {
	print("Yayyy: \"" . $ueppn . "\" you are authorized!"); print "</br>";
	$_SESSION['MY_PHP_AUTH_USER'] = $ueppn;
} else {
	print("Error: \"" . $ueppn . "\" not in authorized list");print "</br>";
}

?>
