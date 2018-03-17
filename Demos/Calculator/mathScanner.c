#include <stdio.h>
#include <stdbool.h>

int state = 1;
char buffer;
int stack[5000];
int* sp = &stack[4999];

void nextToken(int* p){
  char prevcharacter;
  int number;
  //char buffer = getchar();
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
	return;
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
	*p = 1;
	p++;
	*p = number;
	return;
	break;
      }
    case 3:
      state = 1;
      printf("Matched number (0)\n");
      *p = 1;
      p++;
      *p = 0;
      return;
      break;
    case 4:
      state = 1;
      printf("Matched operator %c\n", prevcharacter);
      *p = 0-((int)prevcharacter); //This is negated.  It is negated
      //because in the next steps you cant differentiate between an
      //operator's ASCII number and an actual number.
      p++;
      *p = 0;
      return;
      break;
    case 0:
      break;
    }
  } while((buffer != EOF && buffer != '\n') || state != 1);
}
void push(int* a){
  sp -= 1;
  *sp = a[0];
  sp -= 1;
  *sp = a[1];
  printf("Pushed values %d : %d onto stack", a[0], a[1]);
}
void pop(int* a){
  a[1] = *sp;
  sp += 1;
  a[0] = *sp;
  sp += 1;
  printf("Popped values %d : %d off the stack", a[0], a[1]);
}

int main(){
  buffer = getchar();
  int token[2];
  int pState = 0;
  int element[2] = {0,0};
  push(element);
  nextToken(token);
  bool accepted = false;
  do {
    int tType = token[0];
    int tVal = token[1];
    int sState = sp[1];
    int a[2];
    switch(sState){
    /* Shifts */
    case 0: //+
    case 2: //+
    case 4: //+
    case 5: //+ 
    case 6: //+
	if(tType == '-'){ // Handle subtraction from rule 5
		a[0] = 10;
		a[1] = tVal;
		push(a)
		nextToken(token);
		break;
	}
    case 8: //+
    case 10: //+
    case 11: //+
    case 12: //+
    case 13: //+
	switch(tType){ // Determine what state we are shifting to
		case 1: // state = 1
			a[0] = 1;
		break;
		case '-': // state = 2
			a[0] = 2;
		break;
		case '(': // state = 4
			a[0] = 4; 
		break;
	}
	a[1] = tVal;
	push(a);
	nextToken(token);
    break;
    /* Reductions */
    case 1: //-
	//Rule 3 - number, 1 right-hand
	int b[2];
	pop(b);
    break;
    case 7: //-
    	//Rule 
    case 3: //- 
	//Unused due to the abscence of \n
    case 14: //-
    case 15: //-
    case 18: //-
    case 19: //-
    case 16: //+-
    case 17: //+-
    case 9: // ACCEPT
    break;
    }
  } while (!accepted);
  printf("%d",sp[1]);
}
