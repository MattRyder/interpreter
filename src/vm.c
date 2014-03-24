/* virtual machine */

#include "vm.h"

// parse tree from parser.y
extern NODE* parse_tree;

//setup static vars
static AFRAME *cur_frame;
static AFRAME *top_frame;

static SCOPE *cur_scope;
static SCOPE *top_scope;

static TAG     *cur_tag;
static RBClass *cur_class;

void PUSH_TAG() 
{
   TAG nw_tag;
   nw_tag.frame = cur_frame;
   nw_tag.scope = cur_scope;
   nw_tag.prev_tag = cur_tag;
   cur_tag = &nw_tag;
}

void POP_TAG()
{
  cur_tag = cur_tag->prev_tag;
}

NODE* EXEC_TAG()
{
  return 0; //(NODE*)setjmp(cur_tag->buffer);
}

void vm_init()
{
  static AFRAME frame;
  NODE* rstate;

  cur_frame = top_frame = &frame;
  // boot up the heap to store objs
  
  cur_frame = malloc(sizeof(AFRAME));
  cur_scope = malloc(sizeof(SCOPE));
  

  // set the global scope
  top_scope = cur_scope;

  PUSH_TAG();
  if ((rstate = EXEC_TAG()) == 0)
  {
    
  }
  POP_TAG();

}

void vm_opts(int argc, char** argv)
{
  NODE* rstate;

  PUSH_TAG();
  if((rstate = EXEC_TAG()) == 0)
  {
    //process the argv options
    parse_argv(argc, argv);
  }
}

void vm_exec()
{
}

// Evaluates a Ruby Node and returns the result
static VAL eval_node(NODE* node)
{
  if(!node)
    return 0;

  return vm_evaluate_node(node);

}

static VAL vm_evaluate_node(NODE* node)
{
  VAL result = 0;

  switch(node->flags)
  {
    case NODE_LITERAL:
      //result = (VAL)node->VAL_LITERAL;
      break;
  }

  return result;
}
