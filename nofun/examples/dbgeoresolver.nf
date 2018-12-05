using Google.GeoCoder.Smart;

StoreGeocode {
    Mysql.Do "INSERT INTO geocodes VALUES('$fullAddress',GeomFromText('$gecode'));"
}

groupDataTable = "group$(gid)data"

Mysql.Query "SELECT * FROM $groupDataTable WHERE loc IS NULL;"

addressCount                 = 0
addressesCachedInDatabase    = 0
addressesResolved            = 0
addressErrorsFromGoogle      = 0
addressesWithMultipleResults = 0

foreach(record in records) {
  fullAddress = record.addr" "record.city", "record.state

  Mysql.QueryOne "SELECT AsText(loc) FROM geocodes WHERE fullAddr='$fullAddress';" 
  case Found {
    write log "Address '$fullAddress' found in database\n"
    addressesCachedInDatabase++
    geocode = "POINT("record.lat" "record.lng")"
    StoreGeocode
  } case NotFound {
    write log "Retreiving Address '"fullAddress"' from Google...\n"
    Geocode
    case NotFound {
      write log "Geocode of '$fullAddress' returned error: $error\n"
      addressErrorsFromGoogle++
      continue;
    }

    if(results.length > 1) {
      write log "Geocode of '$fullAddress' returned "results.length" results\n"
      addressesWithMultipleResults++
      continue;
    }

    addressesResolved++
    geocode = "POINT("results[0].lat" "results[0].lng")"
    StoreGeocode
  }
} next { addressCount++ }

write log "-----------------------------------------\n"
write log "Total addresses processed         | $addressCount\n"
write log "-----------------------------------------\n"
write log "Addresses found in cache          | $addressesCachedInDatabase\n"
write log "Addresses resolved from Google    | $addressesResolved\n"
write log "Errors from Google                | $addressErrorsFromGoogle\n"
write log "Addresses with multiple results   | $addressesWithMultipleResults\n"

