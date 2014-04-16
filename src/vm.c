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
   TAG* nw_tag = malloc(sizeof(TAG));
   nw_tag->frame = cur_frame;
   nw_tag->scope = cur_scope;
   nw_tag->prev_tag = cur_tag;
   cur_tag = nw_tag;
}

void POP_TAG()
{ 
  cur_tag = cur_tag->prev_tag;
}

NODE* EXEC_TAG()
{
  return (NODE*)setjmp(cur_tag->buffer);
}

void vm_init()
{
  NODE* rstate;

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
    parse_tree = parse_argv(argc, argv);
  }
  POP_TAG();

  if(rstate != 0) {
    printf("[ERROR] vm_opts failed to ret 0!\n");
    exit(1);
  }
}

// setup stack & heap, evaluate the AST
void vm_exec()
{
  VAL result;
  NODE* rstate;

  init_gc();
  
  PUSH_TAG();
  if((rstate = EXEC_TAG()) == 0)
  {
    printf("[INFO] About to evaluate AST\n\n");
    result = eval_tree(parse_tree);
    printf("\n\n%d\n", result);
  }
  
}

// Evaluates a Ruby Node AST and returns the result
VAL eval_tree(NODE* root_node)
{
  if(!root_node)
    return 0;

  return vm_evaluate_node(root_node);

}

VAL vm_evaluate_node(NODE* node)
{
  VAL result = 0;
  printf("NODE LOCATION: 0x%x\n", node);
  printf("NODE TYPE:     %d\n", node->flags);

  switch(node->flags)
  {
    case NODE_LITERAL:
      printf("Evaluating NODE_LITERAL\n");
      result = (RBNumber*)node->Value1.node;
      break;

    case NODE_CALL:
      printf("Evaluating NODE_CALL\n");
      VAL recv = vm_evaluate_node(node->node_firstval);
      result = vm_methodcall()
      //printf("RECIEVER: %d\n", recv->value); 
      break;

    case NODE_STRING:
      printf("Evaluating NODE_STRING\n");
      result = (RBString*)node->Value1.node;
      break;

    case NODE_NEWLINE:
      printf("Evaluating NODE_NEWLINE\n");
      node = node->node_next;
      printf("2nd node 0x%x", node);
      //vm_evaluate_node(node);
      break;

    default:
      printf("No fucking idea...\n");
      break;

  }

  return result;
}

VAL vm_methodcall(NODE* reciever, )
