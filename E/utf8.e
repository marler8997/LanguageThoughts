


throwable startedInsideCodePoint : invalidData;
throwable missingBytes           : invalidData;

// <func-name> <output-type> ( <inputs> )
// <func-name> <output-type> ( <inouts> ) ( <inputs> )
// <func-name> ( <outputs> ) ( <inouts> ) ( <inputs> )
// 
// if only one output, no name needed

// Note: return value keyword is ret
decodeUtf8Safe unichar (utf8* str)(utf8* limit)
{
  ret = *str;
  str++;
  if(ret <= 0x7F)
    return;
  if((ret & 0x40) == 0)
    throw startedInsideCodePoint;
  if((ret & 0x20) == 0) {
    if(str >= limit) throw missingBytes;
    return ((ret << 6) & 0x7C0) | (*(str++) & 0x3F);
  }
  throw notImplemented;
}

// an sutf8 type does not need to pass in a limit
// because it is guarantted to end with a valid character
// or a null
decodeUtf8 unichar (sutf8* str)()
{
  ret = *str;
  str++;
  if(ret <= 0x7F)
    return;
  if((ret & 0x40) == 0)
    throw startedInsideCodePoint;
  if((ret & 0x20) == 0) {
    return ((ret << 6) & 0x7C0) | (*(str++) & 0x3F);
  }
  throw notImplemented;
}



