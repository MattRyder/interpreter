/* parser.y */

%{

#define YYDEBUG 1
#include ""

%}

/* token data types */
%union {
  NODE *node;
  VALUE val;
  IDENT id;
  int number;
}

/* ruby reserved keywords */
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
/*%token <val>   INTEGER FLOAT STRING

%token <val>   literal numerical

/* operator tokens */
%token PLUS       /* + */
%token MINUS      /* - */
%token PWR        /* ** (implement ^ modification if time) */

/* operator associativity */
%left '+' '-'
%left '*' '/'
%right PLUS MINUS PWR

%%

newline:  /* empty */
       | '\n'
;


%%

// TODO: Setup yylex using flex

