//
// echo [stream] [echo-end-regex]
// echo [stream] // will echo until an empty line is found same as "echo <stream> /^\s*$/
//

Mysql.Row "SELECT * FROM sessions WHERE sid='"sid"';"
case NotFound {
  HttpHeader "Location: /login?frompage=adduser"
  exit
}

echo page
<!DOCTYPE html>
<html>
<head>
  <title>The Campaign App - Add User</title>
  <link rel="stylesheet" href="style.css" type="text/css" />
</head>
<body>
<div class="formpage">

// When an error occurs, it informs the user that an error occured with a reference number
handler error message {
  ref = logWithReference(message)
  ErrorPage "Server Error: if you contact the server admin you can reference this error with the number: "ref
}

// Return an Html page indicating an error occurred
ErrorPage message {
  write page '<h1 class="errormsg">'message'</h1>'
  AddUserForm
  goto FinishPage
}

AddUserForm {

echo page
<h1> Add User </h1>
<table>

write page '<form method="POST" action="adduser.php'urlVars(email)'">'
write page '<tr><td>Email</td><td><input type="text" name="email" 'fiv(email)' /></td></tr>'
write page '<tr><td>Is Administrator</td><td><input type="checkbox" name="isadmin" /></td></tr>'

echo page
<tr><td></td><td><input class="menu-button" type="submit" value="Add User" /></td></tr>
</form>
</table>

// Print current users in database
isset(gid) {
  Mysql.Query "SELECT * FROM regcodes WHERE gid='"gid"';"

  if(records.length > 0) {
    echo page
<h1>Pending Users</h1>
<table>
  <tr><th>Email</th><th>Registration Code</th><th>Is Admin</th><th>Date Added</th></tr>

    foreach(record in records) {
      write page '<tr>'
      write page '<td>'record.email'</td>'
      write page '<td>'record.regcode'</td>'
      write page '<td>'(record.isadmin?"Yes":"No")'</td>'
      write page '<td>'record.gentime'</td>'
      write page '</tr>'
    }
    write page '</table>'
  }
}

// Get current user info
Mysql.QueryOne "SELECT * FROM users WHERE uid='"uid"';"
case NotFound error "uid '"uid"' was not found"

if(!record.isadmin) ErrorPage "You are not an admin of this group"
if(httpMethod == "GET") {
  AddUserForm
  goto FinishPage
}

!isset(email) ErrorPage "Missing email"
!isset(isadmin) ErrorPage "Missing isadmin"

if(!IsValidEmail(email)) ErrorPage "Email '"email"' is invalid"

// Check if email already exists in the regcodes table
Mysql.QueryOne "SELECT regcode FROM regcodes WHERE email='"email"' AND gid="gid";"
case Found error "User with email '"email"' already has a registration code for this group: "record.regcode

// Check if user already exists
Mysql.QueryOne "SELECT * FROM users WHERE email='"email"' AND gid='"gid"';"
case Found ErrorPage "User will email '"email"' is already in this group"

regcode = randomRegCode()
Mysql.Do "INSERT INTO regcodes VALUES ('"email"',"isAdmin",'"regcode"',NOW());"

write page '<h1>Successfully added user "'email'" with regcode : </h1><h2>'regcode'</h2>'
AddUserForm

FinishPage:

echo page
</div>
</body>
</html>
