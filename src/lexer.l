/* lexer.y */

%{
#include <stdio.h>
%}

%option noyywrap
%option yylineno

%{
  // =begin / =end comment syntax 
%}
%x IN_BEGIN_BLOCK

%%

"\0"    |
"\004"  |
"\032"  ;

"#".*             { p("comment", yytext); }

(?i:=begin)     { BEGIN(IN_BEGIN_BLOCK); p("begin block", yytext);  }
<IN_BEGIN_BLOCK>{
(?i:=end) { BEGIN(INITIAL); p("end block", yytext); }
[^\n]+    { p("comment_block text", yytext); }
\n        { yylineno++; }
}

%%

void p(char* type, char* text) {
  printf("[line %d] %s: %s\n", yylineno, type, text);
}

int main(void)
{
  yylex();
  return 0;
}
