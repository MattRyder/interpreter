/* parser.y */

%{
#include <stdio.h>
#include "node.h"
#include "gc.h"

int yylex(void);
int yyerror(const char*);

extern NODE *parse_tree;

/* use defines to map the NodeTypes to create_node calls */
#define MK_MCALL(rec, op, arg) create_node(NODE_CALL, rec, op, arg)
#define MK_LITERAL(literal) create_node(NODE_LITERAL, literal, 0, 0)

%}

%error-verbose 

/* token data types */
%union {
  NODE *node; /* Tri-value Node type                 */
  VAL  val;   /* numeric values / pointer            */
  ID   id;    /* identifier for operation ('+' etc)  */
  STR  str;   /* string data type                    */
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
%type <val>  literal numeric
%type <id>   symbol

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

rbprog    : argument { parse_tree = $1; }

argument  : argument UPLUS argument { $$ = MK_MCALL($1, '+', $3); }
          | initial

initial   : literal { /*$$ = MK_LITERAL($1);*/ }

literal   : SYMB_START symbol { $$ = $2; }
          | numeric

symbol    : GLOBAL_VAR | INSTANCE_VAR

numeric   : INTEGER | FLOAT

%%

NODE* create_node(NodeTypes type, NODE* arg1, NODE* arg2, NODE* arg3)
{
  printf("[create_node]\n");
  NODE *new_node = (NODE *)create_obj();
  new_node->Value1.node = arg1;
  new_node->Value2.node = arg2;
  new_node->Value3.node = arg3;

  new_node->flags |= NFLAG_NODE;

  return new_node;
}


