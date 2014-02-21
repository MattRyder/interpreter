/* parser.y */

%{

#include "rbcore.h"

%}

/* token data types */
%union {
  //NODE *node;
  unsigned int val;
  unsigned int id;
  int number;
}

/* ruby reserved keywords 
%token BEGIN
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

%token <id>    CONSTANT IDENTIFIER GLOBVAR INSTVAR
%token <val>   INTEGER FLOAT STRING

%token <val>   literal numerical

/* operator tokens */
%token UPLUS              /* + */
%token UMINUS             /* - */
%token POWER              /* ** */
%token LEQ                /* <= */
%token GEQ                /* >= */
%token COMP               /* <=> */

%token SGL_EQUAL          /* = */
%token DBL_EQUAL          /* == */
%token NOT_EQUAL          /* != */
%token ASSOCIATION        /* => */
%token MATCH              /* =~ */
%token NOT_MATCH          /* !~ */
%token LSHIFT RSHIFT      /* << and >> */

%token<id> ASSIGN_OP      /* *=, +=, -=, /= */

/* operator associativity */
%left '+' '-'
%left '*' '/'
%right UPLUS UMINUS PWR

%%

dummy: /* empty */
     | "\n" ;

%%


