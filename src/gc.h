/* gc.h */

#ifndef GC_H
#define GC_H

#include "rbcore.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define HEAP_SLOTS 512
#define HEAP_INCREMENT 8

RBBase* create_obj();
void add_heaps();
void init_stack();
void init_gc();

void* rballoc(uint64_t size);
void* rballoc_multi(size_t type, uint64_t num);

// methods to make rb objects
RBString* create_string(char* node_str);

typedef struct rb_value {
  union {
    struct {
      uint32_t flags; // free type flags always 0
      struct rb_value* nextptr;
    } free;
    RBBase   basic;
    RBClass  klass;
    RBString string;
  } type;
} RBValue;

#endif
