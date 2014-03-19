/* gc.c - garbage collector */

#include "gc.h"
#include <stdio.h>

struct rb_base* create_obj()
{
  struct rb_base* new_obj = malloc(sizeof(struct rb_base*));

  return new_obj;
}
