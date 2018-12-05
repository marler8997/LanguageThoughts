Login {
   EmailLookup
   case NotFound {
   }
}

UidLookup {
   Mysql.Row "KEY SELECT * FROM Users WITH '$uid';"
}