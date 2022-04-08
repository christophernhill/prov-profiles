<?php

// Generic redirect func
// print "hello 1 again ronin";
// print "\n";

$ruri=parse_url($_SERVER['REQUEST_URI']);
$rquery=$ruri["query"];

print $rquery;
print "</br>";
// print "\n";

parse_str($rquery,$rqarr);
if ( !array_key_exists("code",$rqarr) ) {
  $err_string="Array key code not found ";
  $_SESSION["LOGIN_ERROR"]="Error in file " . __FILE__ . "</br>" . $err_string;
  header('Location: https://researchcomputing.mit.edu/portal/login_failed');
  exit();
} else {
  // print "hello 2 again ronin";
  // print "\n";
}
$code  = $rqarr["code"];

// Get Location to redirect to
$state = $rqarr["state"];
$nrep=0;
$tloc=preg_replace("/.*_ronin01_/","",$state,1,$nrep);
// Check that last part of redirect location is in controlled DNS space
$tloc_arr=explode(".",$tloc);
$nel=count($tloc_arr);
$domain=$tloc_arr[$nel-2] . "." . $tloc_arr[$nel-1];
if ( strcmp( $domain , "researchcomputing.cloud" ) != 0 ) {
  $emsg="Unregistered redirect domain: " . $domain;
  header('Location: https://researchcomputing.mit.edu/portal/login_failed?error=' . $emsg);
  exit();
}

// Now lets construct token query
// This uses post query
$t_endp='https://cilogon.org/oauth2/token';
$t_client_id='cilogon:/client_id/XXXXX_REPLACE_WITH_OPENID_CONNECT_SERVICE_ENDPOINT_ID_XXXXXX';

// ( keep this secret!! )
$t_client_secret='XXXXX_REPLACE_WITH_OPENID_CONNECT_SECRET_XXXXXXXX'

$t_redirect_uri='https://researchcomputing.mit.edu/portal/authenticate/ronin';
$t_code=$code;
$cauthb64 = "Authorization: Basic " . base64_encode($t_client_id . ':' . $t_client_secret);

$curl = curl_init();
curl_setopt($curl, CURLOPT_URL, $t_endp);
curl_setopt($curl, CURLOPT_POST, true);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$headers = array(
   "Accept: application/json",
   "Content-Type: application/x-www-form-urlencoded",
   $cauthb64,
);
$headers = array(
   "Accept: application/json",
   "Content-Type: application/x-www-form-urlencoded",
);
curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
$gtdata   = "grant_type: authorization_code";
$codedata = "code: " . $t_code;
$redirdata = "redirect_uri: " . $t_redirect_uri;
// $data = <<<DATA
// {
//   urlencode($gtdata),
//   urlencode($codedata),
//   urlencode($redir_uri),
// }
// DATA;
$data = http_build_query( 
         array('grant_type'    => 'authorization_code',
              'client_id'     => $t_client_id,
              'client_secret' => $t_client_secret,
              'code'          => $t_code,
              'redirect_uri'  => $t_redirect_uri,
             )
        );
curl_setopt($curl, CURLINFO_HEADER_OUT, true);
$headerSent = curl_getinfo($curl, CURLINFO_HEADER_OUT );
curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
$resp = curl_exec($curl);
$headerSent = curl_getinfo($curl, CURLINFO_HEADER_OUT );
$info=curl_getinfo($curl);
curl_close($curl);

// print "</br>";
// print($headerSent);

// print "</br>";
// print($resp);

// Now extract and use access token
$jresp = json_decode($resp);
// print "</br>";
// print_r($jresp);
if ( !property_exists($jresp,'id_token') ) {
 print "</br>";
 print "id token not found";
 print "</br>";
 exit();
}
$id_token=$jresp->id_token;
$access_token=$jresp->access_token;

// Now do info query
$u_endp='https://cilogon.org/oauth2/userinfo';
$curl = curl_init();
curl_setopt($curl, CURLOPT_URL, $u_endp);
curl_setopt($curl, CURLOPT_POST, true);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$headers = array(
   "Accept: application/json",
   "Content-Type: application/x-www-form-urlencoded",
);
curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
$data = http_build_query( 
         array('access_token'    => $access_token,
             )
        );
curl_setopt($curl, CURLINFO_HEADER_OUT, true);
$headerSent = curl_getinfo($curl, CURLINFO_HEADER_OUT );
curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
$resp = curl_exec($curl);
$headerSent = curl_getinfo($curl, CURLINFO_HEADER_OUT );
$info=curl_getinfo($curl);
curl_close($curl);
$jresp = json_decode($resp);

$tz=new DateTimeZone("UTC");
$date = new DateTime("now",$tz);
$dts=$date->getTimestamp();
$ucode=urlencode($jresp->eppn . " " . $dts);
// print "</br>";
print $ucode;
print "</br>"; 
print "the end";

// Code to encrypt eppn so that destination can check source is this site
$priv_key=openssl_pkey_get_private('file:///var/www/html/pages/portal/authenticate/XXXX_REPLACE_WITH_PER_PROJECT_PRIVATE_ENCRYPTTION_KEY_XXXX');
$estr=urlencode($ucode);
$eestr='';
$rc=openssl_private_encrypt($estr,$eestr,$priv_key);
$estr=urlencode($eestr);

// Generic redirect func
// print "</br>";
// print "hello 4 again ronin";
// print "\n";
$hloc = "https://" . $tloc . "/index3.php" . "?" . "eppn=" . $ucode . '&' . "enc_eppn=" . $estr;
header("Location: " . $hloc);
exit()
?>
