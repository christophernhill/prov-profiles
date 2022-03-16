<?php
session_start();
$sid=session_id();
?>
<?php
//
// CILOGON RONIN AUTH
$a_end='https://cilogon.org/authorize';
$a_scope='scope='. urlencode('openid+email');
$a_scope='scope='. 'openid+profile+email+org.cilogon.userinfo+edu.uiuc.ncsa.myproxy.getcert';
$a_state='state=' . urlencode($sid . '_ronin01_XXXXREPLACE_WITH_MACHINE_URI_HEREXXXX');
$a_redir='redirect_uri=' . urlencode('https://researchcomputing.mit.edu/portal/authenticate/ronin');
$a_client='client_id=' . 'cilogon:/client_id/18c0a6cf76f9ab6f77134f143524999d';

$h_string='Location: ' . $a_end . '?' . $a_scope . '&' . $a_state . '&' . $a_redir . '&' . $a_client . '&' . 'response_type=code';
header($h_string);
exit();
?>
