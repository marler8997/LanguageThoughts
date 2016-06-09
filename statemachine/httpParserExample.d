
struct JsonParser {
    const char* jsonBuffer;
    const char* limit;

    size_t lineNumber;
    const(char)* offset;
  
    this(const(char)* jsonBuffer, const char* limit)
    {
        this.lineNumber = 1;
        this.jsonBuffer = jsonBuffer;
        this.offset = jsonBuffer;
        this.limit = limit;
    }
    this(const(char)[] json)
    {
        this(json.ptr, json.ptr + json.length);
    }
    
    void consumeWhitespace()
    {
        for(; offset < limit; offset++) {
            auto c = *offset;
            if(c == '\n') {
                lineNumber++;
            } else if(c != ' ' && c != '\t' && c != '\r') {
                return;
            }
        }
    }
    bool parseBool()
    {
        consumeWhitespace();
        if(offset + 3 < limit &&
            offset[0] == 't' &&
            offset[1] == 'r' &&
            offset[2] == 'u' &&
            offset[3] == 'e') {
            offset += 4;
            return 1;
        }
        if(offset + 4 < limit &&
            offset[0] == 'f' &&
            offset[1] == 'a' &&
            offset[2] == 'l' &&
            offset[3] == 's' &&
            offset[4] == 'e') {
            offset += 5;
            return 0;
        }
        throw new Exception("expected bool but got something else");
    }
}
/* statemachine version

statemachine HttpParser {
    http_errno http_errno;

    state error {
    }
    
    this(const(char)* jsonBuffer, const char* limit)
    {
        this.lineNumber = 1;
        this.jsonBuffer = jsonBuffer;
        this.offset = jsonBuffer;
        this.limit = limit;
    }
    this(const(char)[] json)
    {
        this(json.ptr, json.ptr + json.length);
    }
    
    
  
  
}

*/





int main(string[] args)
{
    import std.stdio : writeln, writefln;

    {
        auto parser = JsonParser("true");
        writefln("jsonParseBool('true') is %s", parser.parseBool());
    }
    {
        auto parser = JsonParser("false");
        writefln("jsonParseBool('false') is %s", parser.parseBool());
    }

    return 0;
}



