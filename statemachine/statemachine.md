
# StateMachine

A _statemachine_ is a variation on a _class_/_struct_. It has member fields like it's counterparts, but it also contains named code blocks.  To explain how they work, let's run through an example in C of a json parser using a struct and a statemachine.

```
struct JsonParser {
  int lineNumber;
  char* buffer;
  char* offset;
  char* limit;
};
```
The equivalent _statemachine_ declaration would be:
```
statemachine JsonParser {
  int lineNumber;
  char* buffer;
  char* offset;
  char* limit;
};
```

void jsonParserInit(struct JsonParser* parser, char* buffer, char* limit)
{
    parser->lineNumber = 1;
    parser->buffer = buffer;
    parser->offset = buffer;
    parser->limit = limit;
}
```



  

// StateMachine
// Variation on class/struct





// Example: a udp protocol

void loop()
{
    int udpsocket;
    //...
    while(true) {
      // wait for udp socket
      udpHandler(udpsocket, buffer, bufferlen);
    }
}

statemachine udpHandler(
    int sock,
    char* buffer,
    size_ bufferlen,
    sockaddr from)
{
    int received;

    // first code block is the initial state
    udp_read_handler
    {
        received = recvfrom(udpsocket, buffer, bufferlen);
        if(received < 0) {
          // todo: handle error
        }
        
    }
    
}


// Example: Http Server

event_obj events;


int listenSock = socket(...);
bind(listenSock, ...);
listen(listenSock, ...);

HttpServerStateMachine httpServerStateMachine(events, listenSock);
events.addReadSock(listenSock, httpServerStateMachine);

statemachine HttpServerAcceptStateMachine
{
    readonly event_obj events;
    readonly int listenSock;

    int newSock; // Note: could move this declaration inside a clode block, but it will be moved here
    
    accept
    {
        newSock = accept(sock->s, &addr.base, &addrlen);
        if(newSock == INVALID_SOCKET) {
            log("HttpServerAccept(s=%d) accept failed: %s", sock, strerror(errno));
            // TODO: report error somehow
        }
        log("HttpServerAccept(s=%d) accepted new socket (s=%d)", sock, newSock);
        events.addReadSock(newSock, HttpServerDataStateMachine);
    }
}

statemachine HttpServerDataStateMachine
{
}




