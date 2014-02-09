/* lexer.y */

%{
#include <stdio.h>
%}

%option noyywrap
%option yylineno


%%

"#"   {  }

%%

int main(void)
{
  yylex();
  return 0;
}
