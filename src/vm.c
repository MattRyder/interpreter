/* virtual machine */

#include "vm.h"
#include "getopt.h"

// parse tree from parser.y
extern NODE* parse_tree;

//setup static vars
static AFRAME *cur_frame;
static AFRAME *top_frame;

static SCOPE *cur_scope;
static SCOPE *top_scope;

static TAG     *cur_tag;
static RBClass *cur_class, *class_buffer;

int base_argc;
char **base_argv;

char *script_filename;

NODE* parse_file(char* filename);

char* usage()
{
  return "Usage: %s [-d] [-f filename]\n";
}


/* *****
 * TAG STACK METHODS
 * ***** */
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
  return setjmp(cur_tag->buffer);
}

/* *****
 * CLASS STACK METHODS
 * ***** */
void SAVE_CLASS(RBClass* saveable_class)
{
  class_buffer = saveable_class;
}

RBClass* RESTORE_CLASS()
{
  return class_buffer;
}

/* *****
 * SCOPE STACK METHODS
 * ***** */


/* first point of initialization */
void vm_init()
{
  NODE* rstate;

  cur_frame = malloc(sizeof(AFRAME));
  cur_scope = top_scope = malloc(sizeof(SCOPE));

  // boot up the gc heaps
  init_gc();
  
  PUSH_TAG();
  if ((rstate = EXEC_TAG()) == 0)
  {
    // create a root class object and base frame
    cur_class = malloc(sizeof(RBClass));
    cur_frame->base_node = (NODE*)create_obj();
    cur_frame->base_node->flags = NODE_CONSTREF;
    cur_frame->base_node->Value1.node = (uint32_t)cur_class;
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

    if(parse_tree == 0 || (int)parse_tree == 1)
    {
      exit(parse_tree);
    }
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
 
  PUSH_TAG();
  if((rstate = EXEC_TAG()) == 0)
  {
    printf("[INFO] About to evaluate AST\n\n");
    result = eval_tree(parse_tree);
  }

}

NODE* parse_argv(int argc, char **argv)
{
  int opt = 0;
  NODE *tree;
  base_argc = argc;
  base_argv = argv;
  extern int yydebug;

  while((opt = getopt(argc, argv, "d;f:")) != -1)
  {
    switch(opt)
    {
      case 'd': // debug settings (enable YYDEBUG)
        yydebug = 1;
        printf("[INFO] DEBUG MODE SET\n");
        break;

      case 'f': // ruby script filename
        if(optarg != 0)
        {
          script_filename = optarg;
          printf("[INFO] Loading program from: %s\n", script_filename);
        }
        break;

      default:
        fprintf(stderr, usage(), argv[0]);
        return 0;
    }
  }

  // TODO: parse any params here
  tree = (NODE*)parse_file(script_filename);
  return tree;
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
  // used in calls:
  uint32_t argc;
  VAL* argv;

  VAL result = 0;
  printf("LOCATION: 0x%x", (uint32_t)node);
  printf("\tTYPE: %d \t", node->flags);

  switch(node->flags)
  {
    case NODE_LITERAL:
      printf("Evaluating NODE_LITERAL\n");
      result = ((RBNumber*)node->Value1.node)->value;
      break;

    case NODE_CALL:
      printf("Evaluating NODE_CALL\n");

      VAL recv = vm_evaluate_node(node->node_firstval);
      //evaluate_arguments(node->node_arguments, argc, argv);

      break;

    case NODE_FCALL:
      printf("Evaluating NODE_FCALL\n");
      
      evaluate_arguments(node->node_arguments, argc, argv);
      printf("%s", vm_evaluate_node(node->node_arguments));
      break;

    case NODE_ARRAY:
      printf("Evaluating NODE_ARRAY\n");
      // holy toledo batman, this is unsafe!
      result = vm_evaluate_node(node->node_firstval);
      break;
      

    case NODE_DEFINITION:
      printf("Evaluating NODE_DEFINITON\n");
      if(!node->node_definition) break; // break if nothing to go on...
      
      NODE* method_body;
      uint32_t exception_flags;
      RBClass* method_origin;
      
      // is the method previously defined in the class?
      method_body = get_method_from_class(cur_class, node->node_opid, &method_origin);
      if(method_body && method_origin == cur_class)
      {
        printf("[WARN] Method already registered in this class!\n");
      }

      // work out the ex. status for this method:
      exception_flags = (method_body) ? method_body->node_exflags : node->node_exflags;

      add_method(cur_class, node->node_definition, node->node_opid, exception_flags);
      result = RBNIL;
      break;
      

    case NODE_STRING:
      printf("Evaluating NODE_STRING\n");
      result = ((RBString *)node->Value1.node)->ptr;
      break;

    case NODE_NEWLINE:
      printf("Evaluating NODE_NEWLINE\n");
      node = node->node_next;
      vm_evaluate_node(node);
      break;

    default:
      printf("Cannot find an eval function for %d\n", node->flags);
      break;
  }

  return result;
}

// eval the argv before giving it to a method call
void evaluate_arguments(NODE* node, uint32_t* argc, VAL* argv)
{
  if(!node)
  {
    argv = 0;
    argc = 0;
    return;
  }

  argc = node->Value2.length;
  printf("Trying to extract %d item(s) from node\n", argc);

  // alloc some space for the argv array:
  argv = rballoc_multi(sizeof(VAL), argc);
  
  if(node->flags == NODE_ARRAY)
  {
    for(int i = 0; i < argc; i++)
    {
      argv[i] = vm_evaluate_node(node->node_head);
      node = node->node_next; // next in argv list array
    }
  }
}

VAL vm_methodcall(NODE* reciever, NODE* oper, uint32_t argc)
{
  // check the cache to see if we've seen this reciever before:
  return 0;
}

void add_method(RBClass* mclass, NODE* defn, uint32_t mbody, int exeption_flag)
{
  if(mclass != 0)
  {
    
  }
}

NODE* get_method_from_class(RBClass* mclass, uint32_t method_id, RBClass** method_origin)
{
  NODE* method_body; //method content ptr

  // iterate through the table until 
  while(!find_entry(&mclass->mtd_table, method_id, &method_body) == 0)
  {
    
  }
  return 0;
}
