/* virtual machine */

#ifndef VM_H
#define VM_H

#include <setjmp.h>
#include <stdlib.h>
#include "node.h"
#include "rbcore.h"
#include "gc.h"
#include "symbol_table.h"

// Activation record / stack frame
typedef struct ActivationFrame {
  RBClass* prev_class; //calling class
  NODE* base_node;     //base node from ast
  struct ActivationFrame* prev_frame;
} AFRAME;

typedef struct Scope {
  VAL *local_symbtable;
  VAL *local_variables;
} SCOPE;


typedef struct method_cache_entry {
  NODE* method;
  ID method_id;
  ID exception_flag;
} CACHE_ENTRY;

// wrapper of setjmp to 'fork' and return
typedef struct jmptag {
  jmp_buf buffer;
  AFRAME *frame;
  SCOPE  *scope;
  struct jmptag *prev_tag; //goto prev tag (i.e. linked list adt)
} TAG;

void vm_init(); // initialise the ruby subsystem, heap, scope, stack frame etc.
void vm_opts();
void vm_exec();

NODE* parse_argv(int argc, char **argv);

VAL eval_tree(NODE* root_node);
VAL vm_evaluate_node(NODE* node);
void evaluate_arguments(NODE* node, uint32_t* argc, VAL* argv);

VAL vm_methodcall(NODE* reciever, NODE* oper, uint32_t argc);
void add_method(RBClass* mclass, NODE* defn, uint32_t mbody, int exeption_flag);
NODE* get_method_from_class(RBClass* mclass, uint32_t method_id, RBClass** method_origin);

#endif
