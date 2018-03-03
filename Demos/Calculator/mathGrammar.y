/* Infix notation calculator.  */

%{
  #include <math.h>
  #include <stdio.h>
  int yylex (void);
  void yyerror (char const *);
%}

/* Bison declarations.  */
%token NUM
%left '-' '+'
%left '*' '/'
%precedence NEG   /* negation--unary minus */

%% /* The grammar follows.  */

input:
  '\n'
| exp '\n'
;

exp:
  NUM
| exp '+' exp
| exp '-' exp
| exp '*' exp
| exp '/' exp
| '-' exp  %prec NEG
| '(' exp ')'
;

%%
