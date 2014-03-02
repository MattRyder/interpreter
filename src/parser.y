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
%token <id>    CONSTANT IDENTIFIER GLOBVAR INSTVAR
%token <val>   INTEGER FLOAT STRING
%token <node>  DXSTRING

%token <val>   literal numerical

/* operator tokens */
%token UPLUS              /* + */
%token UMINUS             /* - */
%token POWER              /* ** */
%token LEQ                /* <= */
%token GEQ                /* >= */
%token COMP               /* <=> */
%token AND OR             /* &&, || */

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

dummy: /* empty */
     | "\n" ;

%%


