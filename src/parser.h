#include <stdio.h>
#include "node.h"
#include "gc.h"

int yylex(void);
int yyerror(const char*);

NODE* parse_file(char* filename);
NODE* perform_op(NODE* reciever, ID opsymbol, int has_arg, NODE* arg1);

void init_locals();

NODE* append_block(NODE* first_block, NODE* second_block);
NODE* append_list(NODE* list, NODE* new_element);
NODE* concat_list(NODE* first_list, NODE* second_list);

NODE* assign_variable(ID variable, NODE* new_value);
NODE* assign_attribute(NODE* reciever, ID oper, NODE* value);

static ID* lvar_table();
static void lvar_push();
static void lvar_pop();

static void clsref_pop();

extern int yyin;
extern NODE *parse_tree;

//position tracking, mid-function, end of class etc
static NODE* cur_clsref;
static NODE* mid_method = 0;
static int class_nested = 0;

// local variable table struct
struct local_vtable
{
  ID* table;
  uint32_t nonfree; //prevent vtbl being freed
  uint32_t cnt;     //current table
  struct local_vtable *previous;
};

static struct local_vtable *lvtbl;

/* use defines to map the NodeTypes to create_node calls */
#define MK_FCALL(methd, arg)   create_node(NODE_FCALL, 0, methd, arg)
#define MK_CALL(rec, op, arg)  create_node(NODE_CALL, rec, op, arg)
#define MK_LITERAL(literal)    create_node(NODE_LITERAL, literal, 0, 0)
#define MK_ZEROARRAY()         create_node(NODE_ZARRAY, 0, 0, 0)
#define MK_ARRAY(array)        create_node(NODE_ARRAY, array, 1, 0)
#define MK_LIST(list)          MK_ARRAY(list)
#define MK_HASH(hash)          create_node(NODE_HASH, hash, 0, 0)
#define MK_COLONS(id, var)     create_node(NODE_COLONS, id, var, 0)
#define MK_STRING(string)      create_node(NODE_STRING, string, 0, 0)
#define MK_RETURN(retval)      create_node(NODE_RETURN, retval, 0, 0)
#define MK_IASSIGN(var, val)   create_node(NODE_IASGN, var, val, 0)
#define MK_ARGS(opt, rest, fml) create_node(NODE_ARGS, opt, rest, fml)
#define MK_IF(cond, tru, fal)   create_node(NODE_IF, cond, tru, fal)
#define MK_UNLESS(cond, tru, fal) create_node(NODE_IF, cond, fal, tru)
#define MK_WHILE(cond, block, nd) create_node(NODE_WHILE, cond, block, nd)
#define MK_CLASSREF() (cur_clsref = create_node(NODE_CONSTREF, 0, 0, cur_clsref))
#define MK_SCOPE(block)         create_node(NODE_SCOPE, lvar_table(), block, cur_clsref)
#define MK_RBFUNC(block1, block2) MK_SCOPE(append_block(block1, block2))
#define MK_DEFINITION(fname, args, body, nested)  create_node(NODE_DEFINITION, nested, fname, MK_RBFUNC(args, body))
#define MK_BLOCK(arg)           create_node(NODE_BLOCK, arg, 0, 0)
#define MK_NLNODE(node)         create_node(NODE_NEWLINE, 0, 0, node)
#define MK_MASSIGN(lvar, val)  create_node(NODE_MASGN, lvar, 0, val)
