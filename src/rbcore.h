/* ruby core - rbcore.h */

#ifndef RBCORE_H
#define RBCORE_H

#include <stdint.h>

/* bison tokentype definitions */
typedef uint32_t VAL;
typedef uint32_t ID;
typedef char*    STR;

enum NODE_FLAGS {
  NFLAG_NONE,
  NFLAG_NODE
};

// Base ruby data reqd by descendents
struct rb_base {
  uint32_t classname;
  uint32_t flags;
};

typedef struct rb_class {
  struct rb_base base;
} RBClass;

#endif
