/* parser.y */

%{
#include <stdio.h>
#include "node.h"
%}

%error-verbose 

/* token data types */
%union {
  NODE *node;
  VAL val;
  ID id;
  int number;
}

/* ruby reserved keywords  */
%token BEGINT
       END
       ALIAS
       AND
       CASE
       CLASS
       DEF
       DEFINED
       DO
       ELSE
       ELSIF
       ENSURE
       FOR
       IF
       IN
       MODULE
       NIL
       NOT
       OR
       RESCUE
       RETURN
       SELF
       SUPER
       THEN
       UNDEF
       UNLESS
       UNTIL
       WHEN
       WHILE
       YIELD

%token <id>    CONSTANT IDENTIFIER GLOBAL_VAR INSTANCE_VAR
%token <val>   INTEGER FLOAT STRING
%token <node>  DXSTRING

%type <val>  initial argument
%type <val>   literal numeric
%type <id>    symbol variable fn_name operator

/* operator tokens */
%token UPLUS              /* +   */
%token UMINUS             /* -   */
%token POWER              /* **  */
%token LEQ                /* <=  */
%token GEQ                /* >=  */
%token COMP               /* <=> */
%token BITWISE_AND        /* &&  */
%token BITWISE_OR         /* ||  */

%token SGL_EQUAL          /* =  */
%token DBL_EQUAL          /* == */
%token NOT_EQUAL          /* != */
%token ASSOCIATION        /* => */
%token MATCH              /* =~ */
%token NOT_MATCH          /* !~ */
%token LSHIFT RSHIFT      /* << and >> */
%token COLONS SYMB_START  /* :: and :  */
%token ARRAY_ASSIGN       /* []=       */
%token ARRAY              /* []        */
%token LPAREN RPAREN      /* ( and  )  */

%token<id> ASSIGN_OP      /* *=, +=, -=, /= */

/* operator associativity */
%left '+' '-'
%left '*' '/'
%right UPLUS UMINUS PWR

%%

argument  : argument UPLUS argument { $$ = $1 + $3; printf("%d + %d = %d\n", $1, $3, $$); }
          | initial;

initial   : literal

literal   : SYMB_START symbol | numeric;

symbol    : fn_name | GLOBAL_VAR | INSTANCE_VAR;

fn_name   : operand | operator;

operator  : UPLUS        { $$ = UPLUS;        }
          | UMINUS       { $$ = UMINUS;       }
          | POWER        { $$ = POWER;        }
          | LEQ          { $$ = LEQ;          }
          | GEQ          { $$ = GEQ;          }
          | COMP         { $$ = COMP;         }
          | SGL_EQUAL    { $$ = SGL_EQUAL;    }
          | DBL_EQUAL    { $$ = DBL_EQUAL;    }
          | MATCH        { $$ = MATCH;        }
          | LSHIFT       { $$ = LSHIFT;       }
          | RSHIFT       { $$ = RSHIFT;       }
          | COLONS       { $$ = COLONS;       }
          | ARRAY        { $$ = ARRAY;        }
          | ARRAY_ASSIGN { $$ = ARRAY_ASSIGN; }


variable  : GLOBAL_VAR | INSTANCE_VAR | CONSTANT | IDENTIFIER;
operand   : CONSTANT | IDENTIFIER;
numeric   : INTEGER | FLOAT;

terminals : terminal | terminals ';' { yyerrok; };
terminal  : ','| ';' { yyerrok; } | '\n';

%%


