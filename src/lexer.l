/* lexer.y */

%{
#include "rbcore.h"
#include "parser.tab.h"

void fp();
void p(char* type, char* text);

unsigned char* buffer;

%}

%option yylineno noyywrap

%x IN_BEGIN_CMNT
%x IN_SGL_STRING
%x IN_QUOTED_STRING
%x IN_STRING
%x IN_BACKTICK
%x IN_NUMERIC
%x IN_REGEX
%x IN_GLOBAL

ALIAS               "alias"
AND                 "and"
BEGIN               "begin"
CASE                "case"
CLASS               "class"
DEF                 "def"
DEFINED             "defined?"
DO                  "do"
ELSE                "else"
ELSIF               "elsif"
END                 "end"
ENSURE              "ensure"
FOR                 "for"
IF                  "if"
IN                  "in"
MODULE              "module"
NIL                 "nil"
NOT                 "not"
OR                  "or"
RESCUE              "rescue"
RETURN              "return"
SELF                "self"
SUPER               "super"
THEN                "then"
UNDEF               "undef"
UNLESS              "unless"
UNTIL               "until"
WHEN                "when"
WHILE               "while"
YIELD               "yield"

CONSTANT            [A-Z][A-Za-z_]
IDENTIFIER          [$@]?[a-z_][A-Za-z0-9_]+

ARRAY_ASSIGN        "\[\]\="
ARRAY               "\[\]"

LEFT_PAREN          "("
RIGHT_PAREN         ")"

BEGIN_CMNT_BLOCK    (?i:=begin) 
END_CMNT_BLOCK      (?i:=end)(\r|\n)

SGL_QUOTE           "'"
DBL_QUOTE           "\""
BACKTICK            "`"
QUOTE_START         "%"

GLB_VARIABLE        "$"
GLB_GENERALS        [_*=$?!\"\.\\,<>~@/:;]
GLB_STRMATCH        [&`\'+]|[[:digit:]]+

UPLUS               "+"
UMINUS              "-"

REGEX               "/[^/]*"

POWER               "**"
ADD_ASSIGN_OP       "+="
SUB_ASSIGN_OP       "-="
DIV_ASSIGN_OP       "\\="
MPLY_ASSIGN_OP      "*="
EXPO_ASSIGN_OP      "**="
NOT_ASSIGN_OP       "^="
MOD_ASSIGN_OP       "%="

AND_ASSIGN_OP       "&="
OR_ASSIGN_OP        "|="

SINGLE_EQUAL        "="
DOUBLE_EQUAL        "=="
NOT_EQUAL           "!="
ASSOCIATION         "=>"
MATCH               "=~"
NOT_MATCH           "!~"

COLONS              "::"
SYMBOL_START        ":"

LEQ                 "<="
GEQ                 ">="
COMP                "<=>"
LSHIFT              "<<"
RSHIFT              ">>"

AND                 "&&"
OR                  "||"

HEX_CHARS           [+-]?(?i:0x)[[:xdigit:]]*
OCTAL_CHARS         [+-]?0[\O]*
INTEGERS            [+-]?[0-9]*
FLOATS              [+-]?[0-9]*\.[0-9]*

%%

{UPLUS}            { return UPLUS; }
{UMINUS}           { return UMINUS; }

{ALIAS} { return ALIAS; }               
{AND}   { return AND; }            
{BEGIN} { return BEGIN; }            
{CASE}  { return CASE; }            
{CLASS} { return CLASS; } 
{DEF}   { return DEF: }
{DEFINED} { return DEFINED; }
{DO} { return DO; }
{ELSE} { return ELSE; }
{ELSIF} { return ELSIF; }
{END} { return END; }
{ENSURE} { return ENSURE; }
{FOR} { return FOR; }
{IF} { return IF; }
{IN} { return IN; }
{MODULE} { return MODULE; }
{NIL} { return NIL; }
{NOT} { return NOT; }
{OR}  { return OR; }
{RESCUE} { return RESCUE; }
{RETURN} { return RETURN; }
{SELF} { return SELF; }
{SUPER} { return SUPER; }
{THEN}  { return THEN; }
{UNDEF} { return UNDEF; }
{UNLESS} { return UNLESS; }
{UNTIL} { return UNTIL; }
{WHEN} { return WHEN; }
{WHILE} { return WHILE; }
{YIELD} { return YIELD; }


{COLONS}           { return COLONS;     }
{SYMBOL_START}     { return SYMB_START; }

"#".*              ;
[  \t\f\v]         ;

{BEGIN_CMNT_BLOCK}      { BEGIN(IN_BEGIN_CMNT);       }
{SGL_QUOTE}             { BEGIN(IN_SGL_STRING);       }
{DBL_QUOTE}             { BEGIN(IN_STRING);           }
{BACKTICK}              { BEGIN(IN_BACKTICK);         }
{REGEX}                 { BEGIN(IN_REGEX);            }
{GLB_VARIABLE}          { BEGIN(IN_GLOBAL);           }

{HEX_CHARS}       { yylval.val = strtol(yytext, NULL, 16); return INTEGER; }
{OCTAL_CHARS}     { yylval.val = strtol(yytext, NULL,  8); return INTEGER; }
{FLOATS}          { yylval.val = strtol(yytext, NULL, 10); return FLOAT;   }
{INTEGERS}        { yylval.val = strtol(yytext, NULL, 10); return INTEGER; }

<IN_STRING>{
{DBL_QUOTE}       { BEGIN(0); return STRING; }
[^"]+             { yylval.val = yytext; yymore(); }
<<EOF>>           { yyerror("unterminated string"); return 0; }
}

<IN_SGL_STRING>{
{SGL_QUOTE}       { BEGIN(0); return STRING; }
[^']+             { yylval.val = yytext; yymore(); }
<<EOF>>           { yyerror("unterminated string"); return 0; }
}

<IN_BACKTICK>{
{BACKTICK}        { BEGIN(0); return DXSTRING; }
[^`]+             { yylval.val = yytext; yymore(); }
<<EOF>>           { yyerror("unterminated backtick"); return 0; }
}

<IN_BEGIN_CMNT>{
{END_CMNT_BLOCK}  { BEGIN(0); }
[^\n]+            ;
[\n]              ;
}

<IN_QUOTED_STRING>{
[A-Za-z0-9]       { /* TODO: make a generic string parser for all of the above! */ }
}

<IN_REGEX>{
<<EOF>>           { yyerror("unterminated regex"); return 0; }
}

<IN_GLOBAL>{
[GLB_GENERALS]    {  }
[GLB_STRMATCH]    {  }
.                 { yyerror("invalid char in global variable"); }
}

[\r\n]              {  yylineno++; return '\n'; }

{ARRAY_ASSIGN}    { return ARRAY_ASSIGN;                  }
{ARRAY}           { return ARRAY;                         }

{LEFT_PAREN}      { return LPAREN; }
{RIGHT_PAREN}     { return RPAREN; }

{ADD_ASSIGN_OP}   { yylval.id = '+'; return ASSIGN_OP;    }
{SUB_ASSIGN_OP}   { yylval.id = '-'; return ASSIGN_OP;    }
{MPLY_ASSIGN_OP}  { yylval.id = '*'; return ASSIGN_OP;    }
{DIV_ASSIGN_OP}   { yylval.id = '\\'; return ASSIGN_OP;   }
{EXPO_ASSIGN_OP}  { yylval.id = PWR; return ASSIGN_OP;    }
{AND_ASSIGN_OP}   { yylval.id = '&'; return ASSIGN_OP;    }
{OR_ASSIGN_OP}    { yylval.id = '|'; return ASSIGN_OP;    }
{NOT_ASSIGN_OP}   { yylval.id = '*'; return ASSIGN_OP;    }
{MOD_ASSIGN_OP}   { yylval.id - '%'; return ASSIGN_OP;    }
{LSHIFT}          { yylval.id = LSHIFT; return ASSIGN_OP; }
{RSHIFT}          { yylval.id = RSHIFT; return ASSIGN_OP; }

{NOT_EQUAL}       { return NOT_EQUAL;  }
{NOT_MATCH}       { return NOT_MATCH;  }
{SINGLE_EQUAL}    { return SGL_EQUAL;  }
{DOUBLE_EQUAL}    { return DBL_EQUAL;  }


{POWER}           { return PWR;  }
{LEQ}             { return LEQ;  }
{GEQ}             { return GEQ;  }
{COMP}            { return COMP; }
{AND}             { return AND;  }
{OR}              { return OR;   }

{CONSTANT}        { yylval.id = yytext; return CONSTANT:       }
{IDENTIFIER}      { yylval.id = yytext; return IDENTIFIER;     }
.                 { printf("unrecognised char: %s\n", yytext); }
<<EOF>>           { return 0; }
%%

void fp() {
  //for when I want to do an implicit, fast p()
  p("yybuffer", yytext);
}

void p(char* type, char* text)
{
  printf("[line %d] %s: %s\n", yylineno-1, type, text);
}

int yyerror(char* error_string)
{
  printf("[line %d] error: %s\n", yylineno-1, error_string);
  return 0;
}

int main(int argc, const char* argv[])
{
  int tokid;

  if(argc < 2)
  {
    yyin = stdin;
  } else {
    yyin = fopen(argv[1], "r");
  }

  while(tokid = yylex()) {
    printf("%s : %i\n", yytext,  tokid);
  }
  printf("Done!\n");
  return 0;
}
