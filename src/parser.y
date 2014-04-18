/* parser.y */

%{
#include "parser.h"
%}

%error-verbose

/* token data types */
%union {
  NODE *node;   /* Tri-value Node type                 */
  VAL  val;     /* numeric values / pointer            */
  ID   id;      /* identifier for operation ('+' etc)  */
  STR  str;     /* string data type                    */
  DBL dbl;      /* double-precision float              */
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

%type <val>  literal numeral
%type <id>   symbol operation cls_name fname variable
%type <id>   operator 

%type <node> mcall_arg mcall_args ret_args rhs
%type <node> expr exprs expr_block initial argument arguments lhs method_call command_call
%type <node> fml_arg fml_args fml_list
%type <node> mlhs_block multi_end multi_begin
%type <node> association associations association_list array
%type <node> if_elsif else 

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
%left '*' '/' '|' '&' '^' '%'
%left AND BITWISE_AND OR BITWISE_OR
%left '<' '>' LEQ GEQ LSHIFT RSHIFT

%right '!' '~'
%right OP_ASSIGN UPLUS UMINUS PWR NOT SGL_EQUAL

%nonassoc COLONS
%nonassoc COMP DBL_EQUAL NOT_EQUAL

%%

rbprog    : /* boot */
          {
            init_locals(); 
          }
          | expr_block { parse_tree = $1; }

expr_block : exprs opt_terms


exprs      : expr             { $$ = $1; }
           | exprs terms expr { $$ = append_block($1, MK_NLNODE($3)); }
           | error exprs      { $$ = $2; } /* handle errs at expr level */

expr      : associations { $$ = MK_HASH($1); }
          | RETURN ret_args
            {
              if(!mid_method)
                yyerror("Cannot return from outside a method!");
              
              $$ = MK_RETURN($2);
            }
          | mlhs_block SGL_EQUAL rhs
            {
              $1->node_value = $3;
              $$ = $1;
            }
          | command_call
          | argument


command_call : operation mcall_arg             { $$ = MK_FCALL($1, $2);    }
             | initial '.' operation mcall_arg { $$ = MK_CALL($1, $3, $4); }

mlhs_block  : multi_begin { $$ = MK_MASSIGN(MK_LIST($1), 0); }
            | multi_begin multi_end
              {
                $$ = MK_MASSIGN(concat_list(MK_LIST($1), $2), 0); 
              }

multi_begin : lhs ','

multi_end   : lhs                 { $$ = MK_LIST($1);         }
            | multi_end ',' lhs   { $$ = append_list($1, $3); }

/* Left side of SGL_EQUAL token */
lhs         : variable               { $$ = assign_variable($1, 0);      }
            | initial '.' IDENTIFIER { $$ = assign_attribute($1, $3, 0); }
            | initial '.' CONSTANT   { $$ = assign_attribute($1, $3, 0); }

/* Token -> non-terminal symbol definitions */
cls_name  : IDENTIFIER { yyerror("Class name must be a constant variable"); }
          | CONSTANT

/* function name */
fname     : CONSTANT | IDENTIFIER 
          | operator { $$ = $1;  }

variable  : GLOBAL_VAR | INSTANCE_VAR | IDENTIFIER | CONSTANT
          | NIL  { $$ = NIL;   }
          | SELF { $$ = SELF;  }

/* symbol literal or a numeric data type */
literal   : SYMB_START symbol { $$ = $2; }
          | numeral

/* a valid symbol id, the part after colons (e.g. :mysymbol) */
symbol    : fname | GLOBAL_VAR | INSTANCE_VAR

operation : CONSTANT | IDENTIFIER
 
numeral   : INTEGER | FLOAT

/* Put operators on the AST for function calling later */
operator  : UPLUS        { $$ = UPLUS;        }
          | UMINUS       { $$ = UMINUS;       }
          | '|'          { $$ = '|';          }
          | '^'          { $$ = '^';          }
          | '&'          { $$ = '&';          }
          | '/'          { $$ = '/';          }
          | '%'          { $$ = '%';          }
          | '*'          { $$ = '*';          }
          | PWR          { $$ = PWR;          }
          | ARRAY        { $$ = ARRAY;        }
          | ARRAY_ASSIGN { $$ = ARRAY_ASSIGN; }
          | DBL_EQUAL    { $$ = DBL_EQUAL;    }
          | MATCH        { $$ = MATCH;        }
          | LEQ          { $$ = LEQ;          }
          | GEQ          { $$ = GEQ;          }
          | LSHIFT       { $$ = LSHIFT;       }
          | RSHIFT       { $$ = RSHIFT;       }
          | COLONS       { $$ = COLONS;       }

/* Arguments: return, method params, etc */
argument   : variable SGL_EQUAL argument { $$ = assign_variable($1, $3);           }
           | argument UPLUS argument     { $$ = perform_op($1, '+', 1, $3);        }
           | argument UMINUS argument    { $$ = perform_op($1, '-', 1, $3);        }
           | argument  '/' argument      { $$ = perform_op($1, '/', 1, $3);        }
           | argument '*' argument       { $$ = perform_op($1, '*', 1, $3);        }
           | argument '%' argument       { $$ = perform_op($1, '%', 1, $3);        }
           | argument PWR argument       { $$ = perform_op($1, PWR, 1, $3);        }
           | UPLUS argument              { $$ = perform_op($2, UPLUS, 0, 0);       }
           | UMINUS argument             { $$ = perform_op($2, UMINUS, 0, 0);      }
           | argument '&' argument       { $$ = perform_op($1, '&', 1, $3);        }
           | argument '|' argument       { $$ = perform_op($1, '|', 1, $3);        }
           | argument COMP argument      { $$ = perform_op($1, COMP, 1, $3);       }
           | argument DBL_EQUAL argument { $$ = perform_op($1, DBL_EQUAL, 1, $3);  }
           | initial                     { $$ = $1;                                }   

mcall_args : /* empty */ { $$ = 0; }
           | mcall_arg opt_newline

mcall_arg  : arguments
           | associations               { $$ = MK_LIST(MK_HASH($1));         }
           | arguments ',' associations { $$ = append_list($1, MK_HASH($3)); }


mcall_args : mcall_arg opt_newline

mcall_arg  : arguments
           | associations               { $$ = MK_LIST(MK_HASH($1));         }
           | arguments ',' associations { $$ = append_list($1, MK_HASH($3)); }

arguments  : argument               { $$ = MK_LIST($1);         }
           | arguments ',' argument { $$ = append_list($1, $3); }


/* Array */
array     : /* zero args */ { $$ = 0; }
          | arguments comma_nl


/* Right side of SGL_EQUAL token */
rhs        : arguments
              {
                if($1 && $1->node_next == 0)
                  $$ = $1->node_head;
                else
                  $$ = $1;
              }


ret_args  : mcall_args 
          {
            if ($1->flags == NODE_ARRAY && $1->node_next == 0)
              $$ = $1->node_head;
            else
              $$ = $1;
          }

initial   : literal                       { $$ = MK_LITERAL($1);    }
          | method_call
          | initial COLONS cls_name       { $$ = MK_COLONS($1, $3); }
          | STRING                        { $$ = MK_STRING($1);     }
          | RETURN                        { $$ = MK_RETURN(0);      }
          | RETURN LPAREN RPAREN          { $$ = MK_RETURN(0);      }
          | RETURN ret_args               { $$ = MK_RETURN($2);     }
          | RETURN LPAREN ret_args RPAREN { $$ = MK_RETURN($3);     }
          | '[' array ']'   { $$ = ($2 == 0) ? MK_ZEROARRAY() : $2; }
          | '{' association_list '}'      { $$ = MK_HASH($2);       }
          | CLASS cls_name
            {
              if(mid_method)
                yyerror("Cannot declare a class inside a method body!");

              class_nested++;
              MK_CLASSREF();
              lvar_push();
            }
            expr_block
            END
            {
              class_nested--;
              lvar_pop();
              clsref_pop();
            }
          | IF expr then
            expr_block
            if_elsif
            END
            {
              $$ = MK_IF($2, $4, $5); 
            }
          | WHILE expr term expr_block END { $$ = MK_WHILE($2, $4, 1); }
          | UNLESS expr then
            expr_block
            else
            END
            {
              $$ = MK_UNLESS($2, $4, $5);
            }
          | DEF fname
            {
              if(mid_method)
                yyerror("Cannot declare a definition inside a definition!");
                
              mid_method = $2;
              lvar_push();
            }
            fml_list
            expr_block
            END
            {
              $$ = MK_DEFINITION($2, $4, $5, class_nested ? 0 : 1);
              lvar_pop();
              mid_method = 0;
            }



/* Control Flow (IF, ELSE, THEN etc) */
if_elsif: else
        | ELSIF expr then
          expr_block
          if_elsif { $$ = MK_IF($2, $4, $5); }

else    : /* no opt else */ { $$ = 0;  }
        | ELSE expr_block   { $$ = $2; }

then    : THEN
        | term
        | term THEN


method_call : operation LPAREN mcall_args RPAREN             { $$ = MK_FCALL($1, $3);    }
            | initial '.' operation LPAREN mcall_args LPAREN { $$ = MK_CALL($1, $3, $5); }
            | initial '.' operation { $$ = MK_CALL($1, $3, 0); }
            | initial COLONS operation LPAREN mcall_args RPAREN
              { $$ = MK_CALL($1, $3, $5);  }

/* Formal arguments of method definitions */
fml_list   : LPAREN fml_args RPAREN { $$ = $2; }
           | fml_args term { $$ = $1; }

fml_args   : /* zero args */ { $$ = MK_ARGS(0, 0, -1); }
           | fml_arg         { $$ = MK_ARGS(0, 0, $1); }

fml_arg    : IDENTIFIER { $$ = 1; }
           | fml_arg ',' IDENTIFIER { $$ += 1; /* inc f-arg count */ }



association_list : associations comma_nl { $$ = $1; }

associations : association
             | associations ',' association  { $$ = concat_list($1, $3);          }

association  : argument ASSOCIATION argument { $$ = append_list(MK_LIST($1), $3); }

/* Newlines and statement termination */
comma_nl  : /* empty */
          | '\n'
          | ','

opt_terms   : /* empty */
            | terms

opt_newline : /* empty */
            | '\n'

terms     : term
          | terms ';' { yyerrok; }

term      : '\n'
          | ';' { yyerrok; }


%%

void init_locals()
{
  printf("BOOTING INIT LOCALS\n");
  lvar_push();
}

// calls the bison yyparse fn
// and return the parse tree
NODE* parse_file(char *ruby_script)
{
  yyin = (int)fopen(ruby_script, "r");

  // if yyparse is ok, return the parse tree!
  if(yyparse() == 0)
    return parse_tree;
  
  printf("yyparse failed\n");

  // failed somewhere, return null!
  return 0;
}

NODE* perform_op(NODE* reciever, ID opsymbol, int has_arg, NODE* arg1)
{
  return MK_CALL(reciever, opsymbol, has_arg ? arg1 : 0);
}

NODE* create_node(NodeTypes type, NODE* arg1, NODE* arg2, NODE* arg3)
{
  NODE* new_node = (NODE*)create_obj();
  new_node->Value1.node = arg1;
  new_node->Value2.node = arg2;
  new_node->Value3.node = arg3;

  new_node->flags = type;

  printf("[INFO] Created node of type %d at 0x%x\n", type, (uint32_t)new_node); 
  if(arg1) printf("\targ1: %x\n", (uint32_t)new_node->Value1.node);
  if(arg2) printf("\targ2: %x\n", (uint32_t)new_node->Value2.node);
  if(arg3) printf("\targ3: %x\n", (uint32_t)new_node->Value3.node);
  return new_node;
}

// Append an element to a list and returns the list
NODE* append_list(NODE* list, NODE* new_element)
{
  NODE* tail;
  
  if(list == 0)
    return MK_LIST(new_element);
  
  tail = list;
  while (tail->node_next)
  {
    tail = tail->node_next;
  }

  tail->node_next = MK_LIST(new_element);
  list->node_length += 1;
  return list;
}

//concatenate a list into a single NODE list
NODE* concat_list(NODE* first_list, NODE* second_list)
{
  NODE* last_ptr = first_list;

  // get to the end of the first list:
  while(last_ptr->node_next) 
  {
    last_ptr = last_ptr->node_next;
  }

  // put the 2nd list at the back of the 1st:
  last_ptr->node_next = second_list;

  // member reference error if I access 2ndlist's length directly?! WHY?
  first_list->Value2.length += last_ptr->node_next->node_length;

  return first_list;
}

NODE* append_block(NODE* first_block, NODE* second_block)
{
  NODE* endptr;

  // return first/second depending on nulls
  if(second_block == 0) return first_block;
  if(first_block == 0) return second_block;

  // intern the first node if it's not a block
  if(first_block->flags != NODE_BLOCK)
  {
    endptr = MK_BLOCK(first_block);
    endptr->node_end = endptr;
    first_block = endptr;
  }
  else
  {
    endptr = first_block->node_end;
  }

  // intern the 2nd block if not BLOCK
  if(second_block->flags != NODE_BLOCK)
  {
    second_block = MK_BLOCK(second_block);
    second_block->node_end = second_block;
  }

  // append 2nd block onto 1st
  endptr->node_next = second_block;
  first_block->node_end = second_block->node_end;
  return first_block;
}

NODE* assign_variable(ID variable, NODE* new_value)
{
  // Check we're not reassigning SELF or NIL
  if(variable == SELF)
  {
    yyerror("Cannot change the value of SELF!");
  }
  else if(variable == NIL)
  {
    yyerror("Cannot change the value of NIL!");
  }
  
  // Because I lack scoping at this time, set all as IVARs.
  return MK_IASSIGN(variable, new_value);
}

NODE* assign_attribute(NODE* reciever, ID oper, NODE* value)
{
  return MK_CALL(reciever, oper, MK_LIST(value));
}

static ID* lvar_table()
{
  if(!lvtbl)
  {
    lvtbl = malloc(sizeof(struct local_vtable));
    lvtbl->previous = 0;
    lvtbl->cnt = 0;
  }

  lvtbl->nonfree = 1; // set as not free
  return lvtbl->table;
}

// Push a local variable table onto the stack
static void lvar_push()
{
  struct local_vtable *lvtable;

  lvtable = rballoc(sizeof(struct local_vtable));
  lvtable->nonfree = 0;
  lvtable->cnt     = 0;
  lvtable->previous = lvtbl;
}


// Pop the local variable table off the stack
static void lvar_pop()
{
  struct local_vtable *local_table = lvtbl;

  printf("Popping LVAR table\n");
  // set lvtbl to the previous on the stack
  lvtbl = local_table->previous;
  if(local_table->table)
  {
    printf("local_table has a table!\n");
    local_table->table[0] = local_table->cnt;
    if(local_table->nonfree == 0)
      free(local_table->table);
  }

  free(local_table);
}

static void clsref_pop()
{
  cur_clsref = cur_clsref->node_next;
}
