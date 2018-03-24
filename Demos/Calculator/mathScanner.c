#include <stdio.h>
#include <stdbool.h>

//#define DEBUG

int state = 1;
int buffer_is_empty = 1;
char buffer;
//char prevcharacter;
int stack[5000];
int* sp = &stack[4999];
int* sp_original;

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
  if(buffer_is_empty){
    buffer = getchar();
    buffer_is_empty = 0;
  }
  char prevcharacter;
  int number;
#ifdef DEBUG
  printf("nextToken buff: %c state: %d \n",buffer,state);
#endif
  do{
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
	buffer = getchar();
	break;
      }else if(buffer == '\n'){
#ifdef DEBUG
	printf("Newline\n");
#endif
	buffer_is_empty = 1;
	p[0] = TOKEN_EOL;
	return;
      }else if(buffer == EOF){
#ifdef DEBUG
	printf("EOF\n");
#endif
	p[0] = TOKEN_EOL;
	return;
      }else{
#ifdef DEBUG
	printf("Error token\n");
#endif
	buffer_is_empty = 1;
	p[0] = TOKEN_ERROR;
	return;
      }
  case 2:
      if(buffer >= '0' && buffer <= '9'){
#ifdef DEBUG
	printf("Added number %c\n", buffer);
#endif
	number = number*10 + (buffer - '0');
	prevcharacter = buffer;
	buffer = getchar();
	break;
      }else{
	state = 1;
#ifdef DEBUG
	printf("Matched number %d\n", number);
#endif
	p[0] = TOKEN_NUMBER;
	p[1] = number;
	return;
	break;
      }
  case 3:
    state = 1;
#ifdef DEBUG
    printf("Matched number (0)\n");
#endif
    p[0] = TOKEN_NUMBER;
    p[1] = 0;
    return;
    break;
  case 4:
    state = 1;
#ifdef DEBUG
      printf("Matched operator %c\n", prevcharacter);
#endif
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
      case '(':
	p[0] = TOKEN_LEFTP;
	break;
      case ')':
	p[0] = TOKEN_RIGHTP;
	break;
      }
      p[1] = 0;
      return;
      break;
  case 0:
      break;
  }
  }while(state != 1);
  return;
}
void push(int* a){
  sp -= 1;
  *sp = a[0];
  sp -= 1;
  *sp = a[1];
#ifdef DEBUG
  printf("Pushed values %d : %d onto stack\n", a[0], a[1]);
#endif
}
void pop(int* a){
  a[1] = *sp;
  sp += 1;
  a[0] = *sp;
  sp += 1;
#ifdef DEBUG
  printf("Popped values %d : %d off the stack\n", a[0], a[1]);
#endif
}
void read_in_error(){
  printf("Syntax error\n");
  buffer_is_empty = 1;
  while(getchar() != '\n');
}
void reset_stack(){
#ifdef DEBUG
  printf("Reset stack\n");
#endif
  sp = sp_original;
  sp -= 1;
  *sp = 0;
  sp -= 1;
  *sp = 0;
  printf("> ");
  fflush(stdout);
}

int main(){
  const int gotoLookup[20] = {6,-1,7,-1,8,-1,-1,-1,-1,-1,16,17,18,19,-1,
			      -1,-1,-1,-1,-1};
  int token_is_empty = 1;
  int token[2];
  sp_original = sp;
  int pState = 0;
  int element[2] = {0,0};
  int a[2] = {0,0};
  int b[2] = {0,0};
  reset_stack();
  bool accepted = false;
  do {
    if(token_is_empty){
      nextToken(token);
      token_is_empty = 0;
    }
    int tType = token[0];
    int tVal = token[1];
    int sState = sp[1];
#ifdef DEBUG
    printf("Parse loop, state: %d \n",sState);
#endif
    switch(sState){
    /* Shifts */
    case 0: //+
      switch(tType){
      case TOKEN_NUMBER:
	a[0] = 1;
	a[1] = tVal;
	token_is_empty = 1;
	break;
      case TOKEN_MINUS:
	a[0] = 2;
	token_is_empty = 1;
	break;
      case TOKEN_EOL:
	a[0] = 3;
	break;
      case TOKEN_LEFTP:
	a[0] = 4;
	token_is_empty = 1;
	break;
      default:
#ifdef DEBUG
	printf("Error with token %d\n",tType);
#endif
	read_in_error();
	reset_stack();
	token_is_empty = 1;
	continue;
      }
      push(a);
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
#ifdef DEBUG
	printf("Error with token %d\n",tType);
#endif
	read_in_error();
	reset_stack();
	token_is_empty = 1;
	continue;
      }
      push(a);
      token_is_empty = 1;
    break;
    case 3: //+
      reset_stack();
      token_is_empty = 1;
      if(buffer == EOF) {
	accepted = true; //Temporary
      }
      continue;
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
	pop(b);
       	printf("%d\n",b[1]);
	reset_stack();
	token_is_empty = 1;
	continue;
      default:
#ifdef DEBUG
	printf("Error with token %d\n",tType);
#endif
	read_in_error();
	reset_stack();
	token_is_empty = 1;
	continue;
      }
      push(a);
      token_is_empty = 1;
    break;
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
      case TOKEN_RIGHTP:
	a[0] = 15;
	break;
      default:
#ifdef DEBUG
	printf("Error with token %d\n",tType);
#endif
	read_in_error();
	reset_stack();
	token_is_empty = 1;
	continue;
      }
      push(a);
      token_is_empty = 1;
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
    case 14:
    case 9: // ACCEPT
#ifdef DEBUG
      printf("Error with token %d\n",tType);
#endif
      read_in_error();
      reset_stack();
      token_is_empty = 1;
      continue;      
    case 15: //-
      sp += 2;
      pop(b);
      sp += 2;
      b[0] = gotoLookup[sp[1]];
      push(b);
      break;
    case 18: //-
      pop(a);
      sp += 2;
      pop(b);
      b[1] = a[1] * b[1];
      b[0] = gotoLookup[sp[1]];
      push(b);
      break;
    case 19: //-
      pop(a);
      sp += 2;
      pop(b);
      if(a[1] == 0) {
	printf("Divide by zero\n");
	read_in_error();
	reset_stack();
	token_is_empty = 1;
	continue;
      }
      b[1] = b[1] / a[1];
      b[0] = gotoLookup[sp[1]];
      push(b);
      break;
    case 16: //+-
     if(tType == TOKEN_MULT || tType == TOKEN_DIV){
      switch(tType){
      case TOKEN_MULT:
	a[0] = 12;
	break;
      case TOKEN_DIV:
	a[0] = 13;
	break;
      default:
#ifdef DEBUG
	printf("Error with token %d\n",tType);
#endif
	read_in_error();
        reset_stack();
	token_is_empty = 1;
	continue;
      }
      push(a);
      token_is_empty = 1;
     }else{ /* Reduce */
	pop(a);
	sp += 2;
	pop(b);
	b[1] = b[1] - a[1];
	b[0] = gotoLookup[sp[1]];
	push(b);
     }
    break;
    case 17: //+-
     if(tType == TOKEN_MULT || tType == TOKEN_DIV){
      switch(tType){
      case TOKEN_MULT:
	a[0] = 12;
	break;
      case TOKEN_DIV:
	a[0] = 13;
	break;
      default:
#ifdef DEBUG
	printf("Error with token %d\n",tType);
#endif
	read_in_error();
	reset_stack();
	token_is_empty = 1;
	continue;
      }
      push(a);
      token_is_empty = 1;
     }else{ /* Reduce */
	pop(a);
	sp += 2;
	pop(b);
	b[1] = a[1] + b[1];
	b[0] = gotoLookup[sp[1]];
	push(b);
     }
    break;
    }
  } while (!accepted);
  //printf("%d\n",sp[1]);
}
