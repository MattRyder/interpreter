/* lexer.y */

%{
#include "rbcore.h"
#include "parser.tab.h"

void p(char* type, char* text);

%}

%option yylineno noyywrap

%x IN_BEGIN_CMNT
%x IN_STRING

BEGIN_CMNT_BLOCK    (?i:=begin) 
END_CMNT_BLOCK      (?i:=end)(\r|\n)

DBL_QUOTE           "\""


POWER               "**"
MPLY_ASSIGN_OP      "*="
EXPO_ASSIGN_OP      "**="
SINGLE_EQUAL        "="
DOUBLE_EQUAL        "=="
NOT_EQUAL           "!="
ASSOCIATION         "=>"
MATCH               "=~"
NOT_MATCH           "!~"

LEQ                 "<="
GEQ                 ">="
COMP                "<=>"
LSHIFT              "<<"
RSHIFT              ">>"

%%

"#".*                   ;

{BEGIN_CMNT_BLOCK}      { BEGIN(IN_BEGIN_CMNT); }
{DBL_QUOTE}             { BEGIN(IN_STRING); }

<IN_STRING>{
{DBL_QUOTE}       { BEGIN(0); }
[^"]+             { yylval.val = yytext; yymore(); }
}

<IN_BEGIN_CMNT>{
  {END_CMNT_BLOCK} { BEGIN(0); }
  [^\n]+           ;
  [\n]             { /*yylineno++;*/ }
}

[\n]               {  yylineno++; return '\n'; }

{POWER}            { return PWR; }
{MPLY_ASSIGN_OP}   { yylval.id = '*'; return ASSIGN_OP; }
{EXPO_ASSIGN_OP}   { yylval.id = PWR; return ASSIGN_OP; }
{NOT_EQUAL}        { return NOT_EQUAL; }
{NOT_MATCH}        { return NOT_MATCH; }
{SINGLE_EQUAL}     { p("SINGLE_EQUAL", yytext); return SGL_EQUAL; }
{DOUBLE_EQUAL}     { p("DBL EQUAL", yytext); return DBL_EQUAL; }

{LEQ}              { p("LESS THAN", yytext); return LEQ; }
{GEQ}              { p("GRTR THAN", yytext); return GEQ; }
{COMP}             { p("COMPARE", yytext); return COMP; }

{LSHIFT}           { p("L SHIFT", yytext); yylval.id = LSHIFT; return ASSIGN_OP; }
{RSHIFT}           { p("R SHIFT", yytext); yylval.id = RSHIFT; return ASSIGN_OP; }

.                  { p("unrecognised char", yytext); }
<<EOF>>            { return 0; }
%%

void p(char* type, char* text)
{
  printf("[line %d] %s: %s\n", yylineno, type, text);
}

int main(int argc, const char* argv[])
{
  FILE* fp;

  if(argc < 2)
  {
    yyin = stdin;
  } else {
    yyin = fopen(argv[1], "r");
  }

  while(yylex());
  printf("Done!\n");
  return 0;
}
