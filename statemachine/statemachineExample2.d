


//
// Not the best example, but should work
//
statemachine ArrayIterator(T)
{
    T* ptr;
    T* limit;
    this(T[] array)
    {
        if(array.length == 0) {
            empty.state = end;
        } else {
            empty.state = moreElements;
            this.ptr = array.ptr;
            this.limit = array.ptr + array.length;
        }
    }
    bool empty()
    {
        state moreElements {
            return false;
        }
        state end {
            return true;
        }
    }
    void popFront()
    {
        ptr++;
        if(ptr >= limit) {
            empty.state = end;
        }
    }
    T front
    {
        return *ptr;
    }
}


statemachine HttpParser
{
    size_t execute(http_parser_settings* settings, const(char)* data, const(char)* limit)
    {
        state startRequestOrResponse {
        }
        
    }
}


//
//

enum HttpParserType { request, response, both }; // takes 2 bits

struct HttpParser
{
    HttpParserType type;
    HttpParserSettings* settings;
    void execute(const(char)* data, const(char)* limit)
    {
        while(data < limit) {
            HttpParserStateMachine.c = *data;
            HttpParserStateMachine();
        }
    }
    // The statemachine is declared inside a struct which
    // means it will include it's memory inside the struct and have access to
    // the struct's fields
    statemachine HttpParserStateMachine
    {
        char c;
        ubyte flags;
        ulong contentLength;
        state startRequestOrResponse {
            flags = 0;                 // reset flags
            contentLength = ulong.max; // reset contentLength
            if(c != 'H') {
                type = HttpParserType.request;
                goto startRequest; // sets the state to startRequest and immediately executes it
            }
            state = requestOrResponseH;
            settings.messageBegin();
        }
        state requestOrResponse {
            // TODO: implement
        }
    }

}








