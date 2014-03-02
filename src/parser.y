/* parser.y */

%{
#include "node.h"
%}

/* token data types */
%union {
  struct Node *node;
  unsigned int val;
  unsigned int id;
  int number;
}

/* ruby reserved keywords  */
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
%token <node>  DXSTRING

%type <val>   literal numerical

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
%token COLONS SYMB_START  /* :: and : */
%token ARRAY_ASSIGN       /* []=      */
%token ARRAY              /* []       */
%token LPAREN RPAREN


%token<id> ASSIGN_OP      /* *=, +=, -=, /= */

/* operator associativity */
%left '+' '-'
%left '*' '/'
%right UPLUS UMINUS PWR

%%

literal:   numerical
       |   SYMBOL_START

function_name: IDENTIFIER

numerical: INTEGER | FLOAT;

dummy: /* empty */
     | "\n" ;

%%


