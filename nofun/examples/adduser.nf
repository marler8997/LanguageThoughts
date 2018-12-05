generator randomRegCode() {
  // Need regcodeLength
  regcodeMap = '123456789abcdefghijkmnpqrstuvwxyz'; /*omit 0,o and l, they look kinda ambiguous*/
  for(i = 0; i < regcodeLength; i++) {
    regcode[i] = regcodeMap[rand(0,recodeMap.length)];
  }
  return regcode;
}

AddUser {
  MysqlQueryOne "SELECT * FROM regcodes WHERE email='"email"' AND gid='"gid"';"
  case Found goto case UserExists
  MysqlDo "INSERT INTO regcodes VALUES ('"email"',"isAdmin",'"randomRegCode()"',NOW());"
}