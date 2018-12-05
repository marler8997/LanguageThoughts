#include <stdio.h>



// NextChar assumptions:
//    the input c is an int
//    END_OF_INPUT is a label to handle the end of input
#define NextChar(c) c = getchar();if(c == EOF) goto END_OF_INPUT





int main(int argc, char *argv[])
{
  int c;

  
  while(1) {
    NextChar(c);

    

    
  }






  return 0;




 END_OF_INPUT:


  return -1;

}
