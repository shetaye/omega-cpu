#include <stdio.h>
#include <stdbool.h>

int state = 1;
//char buffer;
int stack[5000];
int* sp = &stack[4999];

typedef enum {
  TOKEN_NUMBER,
  TOKEN_PLUS,
  TOKEN_MINUS,
  TOKEN_MULT,
  TOKEN_DIV,
  TOKEN_LEFTP,
  TOKEN_RIGHTP,
  TOKEN_ERROR,
  TOKEN_EOL
} TOKENS;

void nextToken(int* p){
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
      }else if(buffer == ' ' || buffer == '\t'){
	state = 1;
	break;
      }else{
	printf("Syntax error\n");
	p[0] = TOKEN_ERROR;
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
	p[0] = TOKEN_NUMBER;
	p[1] = number;
	return;
	break;
      }
    case 3:
      state = 1;
      printf("Matched number (0)\n");
      p[0] = TOKEN_NUMBER;
      p[1] = 0;
      return;
      break;
    case 4:
      state = 1;
      printf("Matched operator %c\n", prevcharacter);
      switch(prevcharacter){
      case '+':
	p[0] = TOKEN_PLUS;
	  break;
      case '-':
	p[0] = TOKEN_MINUS;
	  break;
      case '/':
	p[0] = TOKEN_DIV;
	  break;
      case '*':
	p[0] = TOKEN_MULT;
	  break;
      }
      p[1] = 0;
      return;
      break;
    case 0:
      break;
    }
  } while((buffer != EOF && buffer != '\n') || state != 1);
  p[0] = TOKEN_EOL;
}
void push(int* a){
  sp -= 1;
  *sp = a[0];
  sp -= 1;
  *sp = a[1];
  printf("Pushed values %d : %d onto stack\n", a[0], a[1]);
}
void pop(int* a){
  a[1] = *sp;
  sp += 1;
  a[0] = *sp;
  sp += 1;
  printf("Popped values %d : %d off the stack\n", a[0], a[1]);
}

int main(){
  //buffer = getchar();
  const int gotoLookup[20] = {6,-1,7,-1,8,-1,-1,-1,-1,-1,16,17,18,19,-1,
			      -1,-1,-1,-1,-1};
  int token[2];
  int *sp_original = sp;
  int pState = 0;
  int element[2] = {0,0};
  int a[2], b[2];
  push(element);
  nextToken(token);
  bool accepted = false;
  do {
    int tType = token[0];
    int tVal = token[1];
    int sState = sp[1];
    switch(sState){
    /* Shifts */
    case 0: //+
      switch(tType){
      case TOKEN_NUMBER:
	a[0] = 1;
	a[1] = tVal;
	break;
      case TOKEN_MINUS:
	a[0] = 2;
	break;
      case TOKEN_EOL:
	a[0] = 3;
	break;
      case TOKEN_LEFTP:
	a[0] = 4;
	break;
      default:
	printf("Error with token %d\n",tType);
	sp = sp_original;
	element[0] = 0;
	element[1] = 0;
	push(element);
	continue;
      }
      push(a);
      nextToken(token);
    break;
    case 2: //+
    case 4: //+
    case 10: //+
    case 11: //+
    case 12: //+
    case 13: //+
      switch(tType){ // Determine what state we are shifting to
      case TOKEN_NUMBER: // state = 1
	a[0] = 1;
	a[1] = tVal;
	break;
      case TOKEN_MINUS: // state = 2
	a[0] = 2;
	break;
      case TOKEN_LEFTP: // state = 4
	a[0] = 4; 
	break;
      default:
	printf("Error with token %d\n",tType);
	sp = sp_original;
	element[0] = 0;
	element[1] = 0;
	push(element);
	continue;
      }
      push(a);
      nextToken(token);
    case 3: //+
      sp = sp_original;
      element[0] = 0;
      element[1] = 0;
      push(element);
      break;
    case 6: //+
      switch(tType){
      case TOKEN_MINUS:
	a[0] = 10;
	break;
      case TOKEN_PLUS:
	a[0] = 11;
	break;
      case TOKEN_MULT:
	a[0] = 12;
	break;
      case TOKEN_DIV:
	a[0] = 13;
	break;
      case TOKEN_EOL:
	a[0] = 14;
	break;
      default:
	printf("Error with token %d\n",tType);
	sp = sp_original;
	element[0] = 0;
	element[1] = 0;
	push(element);
	continue;
      }
      push(a);
      nextToken(token);
    case 8:
      switch(tType){
      case TOKEN_MINUS:
	a[0] = 10;
	break;
      case TOKEN_PLUS:
	a[0] = 11;
	break;
      case TOKEN_MULT:
	a[0] = 12;
	break;
      case TOKEN_DIV:
	a[0] = 13;
	break;
      case TOKEN_LEFTP:
	a[0] = 15;
	break;
      default:
	printf("Error with token %d\n",tType);
	sp = sp_original;
	element[0] = 0;
	element[1] = 0;
	push(element);
	continue;
      }
      push(a);
      nextToken(token);
    break;
    /* Reductions */
    case 1: //-
	//Rule 3 - number, 1 right-hand
	pop(b);
	b[0] = gotoLookup[sp[1]];
	push(b);
    break;
    case 7: //-
      pop(b);
      sp += 2;
      b[1] = -b[1];
      b[0] = gotoLookup[sp[1]];
      push(b);
      break;
    case 5: //-
    case 9: // ACCEPT
      printf("Error with token %d\n",tType);
      sp = sp_original;
      element[0] = 0;
      element[1] = 0;
      push(element);
      continue;      
    case 14: //-
      sp += 2;
      pop(b);
      element[0] = 0;
      element[1] = 0;
      push(element);
      printf("%d\n",b[1]);
      sp = sp_original;
      continue;
    case 15: //-
      sp += 2;
      pop(b);
      sp += 2;
      b[0] = gotoLookup[sp[1]];
      push(b);
    case 18: //-
      pop(a);
      sp += 2;
      pop(b);
      a[1] = a[1] * b[1];
      b[0] = gotoLookup[sp[1]];
      push(b);
    case 19: //-
      pop(a);
      sp += 2;
      pop(b);
      a[1] = a[1] / b[1];
      b[0] = gotoLookup[sp[1]];
      push(b);
    case 16: //+-
      switch(tType){
      case TOKEN_MULT:
	a[0] = 12;
	break;
      case TOKEN_DIV:
	a[0] = 13;
	break;
      default:
	printf("Error with token %d\n",tType);
	sp = sp_original;
	element[0] = 0;
	element[1] = 0;
	push(element);
	continue;
      }
      push(a);
      nextToken(token);
    case 17: //+-
      switch(tType){
      case TOKEN_MULT:
	a[0] = 12;
	break;
      case TOKEN_DIV:
	a[0] = 13;
	break;
      default:
	printf("Error with token %d\n",tType);
	sp = sp_original;
	element[0] = 0;
	element[1] = 0;
	push(element);
	continue;
      }
      push(a);
      nextToken(token);
    break;
    }
  } while (!accepted);
  printf("%d\n",sp[1]);
}
