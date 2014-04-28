/* lexer.y */

%{
#define YYERROR_VERBOSE 1

#include "rbcore.h"
#include "node.h"
#include "parser.tab.h"

int yyerror(char*);

void fp();
void p(char* type, char* text);
RBNumber* create_rbnumeric(char* num_str, int base);

// defined in gc.c
RBString* create_string(char* node_str);
RBNumber* create_number(uint32_t prim_num);


// root node that holds the parse tree
NODE *parse_tree = 0;

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

CONSTANT            [A-Z]+[A-Za-z_]*
IDENTIFIER          [a-z_]+[A-Za-z0-9_]*
GLOBAL_VAR          [$]{IDENTIFIER}
INSTANCE_VAR        [@]{IDENTIFIER}


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

LOGICAL_AND         "&&"
LOGICAL_OR          "||"
BITWISE_AND         "&"
BITWISE_OR          "|"

HEX_CHARS           [+-]?(?i:0x)[[:xdigit:]]*
OCTAL_CHARS         [+-]?0[\O]*
INTEGERS            [+-]?[0-9]+
FLOATS              [+-]?[0-9]+\.[0-9]*

%%

{UPLUS}            { return UPLUS; }
{UMINUS}           { return UMINUS; }

{ALIAS}     { return ALIAS;   }               
{AND}       { return AND;     }            
{BEGIN}     { return BEGINT; /* BEGIN taken by Flex! */ }            
{CASE}      { return CASE;    }            
{CLASS}     { return CLASS;   } 
{DEF}       { return DEF;     }
{DEFINED}   { return DEFINED; }
{DO}        { return DO;      }
{ELSE}      { return ELSE;    }
{ELSIF}     { return ELSIF;   }
{END}       { return END;     }
{ENSURE}    { return ENSURE;  }
{FOR}       { return FOR;     }
{IF}        { return IF;      }
{IN}        { return IN;      }
{MODULE}    { return MODULE;  }
{NIL}       { return NIL;     }
{NOT}       { return NOT;     }
{OR}        { return OR;      }
{RESCUE}    { return RESCUE;  }
{RETURN}    { return RETURN;  }
{SELF}      { return SELF;    }
{SUPER}     { return SUPER;   }
{THEN}      { return THEN;    }
{UNDEF}     { return UNDEF;   }
{UNLESS}    { return UNLESS;  }
{UNTIL}     { return UNTIL;   }
{WHEN}      { return WHEN;    }
{WHILE}     { return WHILE;   }
{YIELD}     { return YIELD;   }


{COLONS}           { return COLONS;     }
{SYMBOL_START}     { return SYMB_START; }

"#".*\n            ;
[  \t\f\v]         ;

{BEGIN_CMNT_BLOCK}      { BEGIN(IN_BEGIN_CMNT);       }
{SGL_QUOTE}             { BEGIN(IN_SGL_STRING);       }
{DBL_QUOTE}             { BEGIN(IN_STRING);           }
{BACKTICK}              { BEGIN(IN_BACKTICK);         }
{REGEX}                 { BEGIN(IN_REGEX);            }
{GLB_VARIABLE}          { BEGIN(IN_GLOBAL);           }

[\.\,\^\[\]\;] { return yytext[0]; }

{HEX_CHARS}       { yylval.val = strtol(yytext, NULL, 16); return INTEGER; }
{OCTAL_CHARS}     { yylval.val = strtol(yytext, NULL,  8); return INTEGER; }
{FLOATS}          { yylval.dbl = atof(yytext); return FLOAT;               }
{INTEGERS}        { yylval.val = create_rbnumeric(yytext, 10); return INTEGER; }

<IN_STRING>{
{DBL_QUOTE}       { BEGIN(0); return STRING; }
[^"]+             { yylval.val = create_string(yytext); yymore(); }
<<EOF>>           { yyerror("unterminated string"); return 0; }
}

<IN_SGL_STRING>{
{SGL_QUOTE}       { BEGIN(0); return STRING; }
[^']+             { yylval.str = yytext; yymore(); }
<<EOF>>           { yyerror("unterminated string"); return 0; }
}

<IN_BEGIN_CMNT>{
{END_CMNT_BLOCK}  { BEGIN(0); }
[^\n]+            ;
[\x0A]              ;
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

\n             {  yylineno++; return '\n'; }

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
{MOD_ASSIGN_OP}   { yylval.id = '%'; return ASSIGN_OP;    }
{LSHIFT}          { yylval.id = LSHIFT; return ASSIGN_OP; }
{RSHIFT}          { yylval.id = RSHIFT; return ASSIGN_OP; }

{ASSOCIATION}     { return ASSOCIATION; }
{NOT_EQUAL}       { return NOT_EQUAL;   }
{NOT_MATCH}       { return NOT_MATCH;   }
{SINGLE_EQUAL}    { return SGL_EQUAL;   }
{DOUBLE_EQUAL}    { return DBL_EQUAL;   }


{POWER}           { return PWR;  }
{LEQ}             { return LEQ;  }
{GEQ}             { return GEQ;  }
{COMP}            { return COMP; }
{BITWISE_AND}     { return '&';  }
{BITWISE_OR}      { return '|';  }
{LOGICAL_AND}     { return BITWISE_AND;  }
{LOGICAL_OR}      { return BITWISE_OR;   }

{CONSTANT}        { yylval.str = yytext; return CONSTANT;       }
{GLOBAL_VAR}      { yylval.str = yytext; return GLOBAL_VAR;     }
{INSTANCE_VAR}    { yylval.str = yytext; return INSTANCE_VAR;   }
{IDENTIFIER}      { yylval.str = yytext; return IDENTIFIER;     }

"/"               { return '/'; }
"*"               { return '*'; }

.                 { return yyerror("unrecognised char"); }
<<EOF>>           { return 0; }
%%

RBNumber* create_rbnumeric(char* num_str, int base)
{
  uint32_t num = strtol(num_str, NULL, base);
  return create_number(num);
}

void p(char* type, char* text)
{
  printf("[line %d] %s: %s\n", yylineno-1, type, text);
}

int yyerror(char* error_string)
{
  printf("[line %d] error: %s. %s\n", yylineno, error_string, yytext);
  return -1;
}
