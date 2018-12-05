
result = MysqlSession
case NoSession {
  HttpHeader "Location: /login"
  exit
}

// since result is an array, this means sid is
// an alias for result[0], genTime is an alias for result[1]
// and so on
result : sid genTime uid gid lastRequest ip
if(gid == null) {
  HttpHeader "Location: /choosegroup"
  exit
}

HttpHeader "Content-Type: application/json"
json = new JsonObject

result = Mysql.QueryOne "SELECT isadmin FROM users2groups WHERE uid=$uid AND gid=$gid;"
case NotFound {
  // The DatabaseCorrupt function logs an error message,
  // the second argument is an enum of the type of corruption
  // the third argument is the table name missing the row
  // the fourth argument is the WHERE statement of the missing row
  DBCorrupt RowMissing users2groups "uid=$uid AND gid=$gid"
  JsonErrorAndExit "Could not determine if you are an admin"
}
isadmin = result[0]; // same as result : isadmin

if(!isset($_REQUEST['op'])) {$json->ex('Missing request variable "op"');}

$op = $_REQUEST['op'];
if($op == "current") {
  MysqlJsonPrintUsers($json, $gid, $uid);
  $json->endAll();
  exit();
}

  if(!$isadmin) {$json->ex('Permission Denied: You are not an admin');}
  if($op == "pending") {
    MysqlJsonPrintPendingUsers($json, $gid, $uid);
    $json->endAll();
    exit();
  }

  $userIsadmin = isset($_REQUEST['isadmin']) ? 1 : 0;

  if($op == 'addone') {
    if(!isset($_REQUEST['email'])) {$json->ex('Missing request variable "email"');}
    $userEmail = trim($_REQUEST["email"]);
    if(empty($userEmail)) {$json->ex('Request variable "email" is empty');}
    if(!IsValidEmail($userEmail)) {$json->ex("Invalid email '$userEmail'");}


    // Check if user already exists in this group
    $result = MysqlQueryOne("SELECT uid FROM users WHERE email='$userEmail';");
    if($result !== 0) {
      list($userUid) = $result;
      $result = MysqlQuery("SELECT * FROM users2groups WHERE uid=$userUid AND gid=$gid;");
      if(MysqlCount($result) > 0) {$json->ex("User with email '$userEmail' has already been registered with this group");}
    }

    // Check if email already exists in the regcodes table
    $result = MysqlQuery("SELECT regcode FROM regcodes WHERE email='$userEmail' AND gid=$gid;");
    if(MysqlCount($result) > 0) {
      list($regcode) = mysql_fetch_row($result);
      $json->ex("User with email '$userEmail' already exists with regcode '$regcode'");
    }

    $regcode = GenerateRegcode();
    MysqlQuery("INSERT INTO regcodes VALUES ('$userEmail','$regcode',$gid,$userIsadmin,NOW());");

  } elseif($op == 'addmultiple') {
    $badEmails = array();
    $alreadyRegistered = array();
    $alreadyPending = array();

    $userEmails = file_get_contents('php://input');
    $userEmails = SplitEmails($userEmails);
    $userEmailsCount = count($userEmails);
    foreach($userEmails as $userEmail) {
      $userEmail = trim($userEmail);
      if(empty($userEmail)) {continue;}
      if(!IsValidEmail($userEmail)) {
        array_push($badEmails,$userEmail);
	continue;
      }

      // Check if user already exists in this group
      $result = MysqlQueryOne("SELECT uid FROM users WHERE email='$userEmail';");
      if($result !== 0) {
        list($userUid) = $result;
        $result = MysqlQuery("SELECT * FROM users2groups WHERE uid=$userUid AND gid=$gid;");
        if(MysqlCount($result) > 0) {
	  array_push($alreadyRegistered, $userEmail);
	  continue;
	}
      }

      // Check if email already exists in the regcodes table
      $result = MysqlQuery("SELECT regcode FROM regcodes WHERE email='$userEmail' AND gid=$gid;");
      if(MysqlCount($result) > 0) {
        list($regcode) = mysql_fetch_row($result);
	array_push($alreadyPending, $userEmail);
	continue;
      }

      $regcode = GenerateRegcode();
      MysqlQuery("INSERT INTO regcodes VALUES ('$userEmail','$regcode',$gid,$userIsadmin,NOW());");
    }

    // Return Errors
    $badEmailsCount = count($badEmails);
    if($badEmailsCount > 0) {
      $json->addArray('badEmails', $badEmails);
    } else {
      $json->addNull('badEmails');
    }

    $alreadyRegisteredCount = count($alreadyRegistered);
    if($alreadyRegisteredCount > 0) {
      $json->addArray('alreadyRegistered', $alreadyRegistered);
    } else {
      $json->addNull('alreadyRegistered');
    }

    $alreadyPendingCount = count($alreadyPending);
    if($alreadyPendingCount > 0) {
      $json->addArray('alreadyPending', $alreadyPending);
    } else {
      $json->addNull('alreadyPending');
    }

    // Return Count
    $json->addNumber('added',$userEmailsCount - $badEmailsCount - $alreadyRegisteredCount - $alreadyPendingCount);
  } else {
    $json->ex("Unknown op '$op'");
  }

  $json->endAll();

} catch(MysqlException $me) {
  if($json == null) {
    header("Content-Type: application/json");
    $json = new JsonObject();
  }
  $json->ex('Server Error: your reference number is '.$me->logRefNum);
}

?>