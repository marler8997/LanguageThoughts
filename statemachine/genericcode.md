



swap
{
    temp = args[0];
    args[0] = args[1];
    args[1] = temp;
}
// Block Parser Output
// ---------------------------------------
// 2 arguments
// args[0] no-name affects [temp, args[1]]
// args[1] no-name affects [args[0]]
// 1 variable
// vars[0] temp affects [args[1]]


// C usage

// Specify swap should be a function

GENERATE_FUNCTION(swap, int, int)
// By default the function variables are just regular function variables on the stack
void swap(int _0, int _1)
{
    int temp;
    temp = _0;
    _0 = _1;
    _1 = temp;
}






helloWorld
{
    writeln "Hello, World!";
}
// Block Parser Output
// ---------------------------------------
// 0 arguments
// 0 variables
// 1 output
// 1 string-literal
// 0: "Hello, World!"



//
// OS/Shell Program
// 
//
// Environment: Keyboard somehow
//

// uid = User Input Device

uidDriver
{
    serviceInterrupt
    {
        stateChange : uint32 = args[0];
        
    }
}



shell
{
    uidCallback
    {
        
    }

    injectCallback(uid, uiCallback);
    
}







