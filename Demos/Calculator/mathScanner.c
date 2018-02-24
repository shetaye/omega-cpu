#include <stdio.h>



int main(){
  int state = 1;
  char prevcharacter;
  int number;
  char buffer = getchar();
  do {
    //printf("%c\n",buffer);
    switch(state){
    case 1:
      if(buffer == '0'){
	state = 3;
	number = 0;
	prevcharacter = buffer;
	buffer = getchar();
	break;
      }else if(buffer >= '1' && buffer <= '9'){
	state = 2;
	number = buffer - '0';
	prevcharacter = buffer;
	buffer = getchar();
	break;
      }else if(buffer == '+' || buffer == '-' || buffer == '*' || buffer == '/' || buffer == '(' || buffer == ')'){
	state = 4;
	prevcharacter = buffer;
	buffer = getchar();
	break;
      }else{
	printf("Syntax error\n");
	return 1;
      }
    case 2:
      if(buffer >= '0' && buffer <= '9'){
	number = number*10 + (buffer - '0');
	prevcharacter = buffer;
	buffer = getchar();
	break;
      }else{
	state = 1;
	printf("Matched number %d\n", number);
	break;
      }
    case 3:
      state = 1;
      printf("Matched number (0)\n");
      break;
    case 4:
      state = 1;
      printf("Matched operator %c\n", prevcharacter);
      break;
    }
  } while((buffer != EOF && buffer != '\n') || state != 1);
  return 0;
}
