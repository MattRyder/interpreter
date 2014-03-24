/* gc.h */

#ifndef GC_H
#define GC_H

#include "rbcore.h"
#include <stdlib.h>
#include <stdio.h>

#define HEAP_SLOTS 512
#define HEAP_INCREMENT 8

RBBase* create_obj();
void add_heaps();
void init_stack();
void init_heap();

void* rballoc(uint64_t size);

typedef struct rb_value {
  union {
    struct {
      uint32_t flags; // free type flags always 0
      struct rb_value* nextptr;
    } free;
    RBBase  basic;
    RBClass class;
  } type;
} RBValue;

#endif
