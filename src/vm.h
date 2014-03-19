/* virtual machine */

#ifndef VM_H
#define VM_H

#include <setjmp.h>
#include <stdlib.h>
#include "node.h"
#include "rbcore.h"

// Activation record / stack frame
typedef struct ActivationFrame {
  RBClass *prev_class; //calling class
} AFRAME;

typedef struct Scope {
  VAL *local_symbtable;
  VAL *local_variables;
} SCOPE;

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

static VAL vm_evaluate_node(NODE* node);

#endif
