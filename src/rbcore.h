/* ruby core - rbcore.h */

#ifndef RBCORE_H
#define RBCORE_H

#include <stdint.h>

/* bison tokentype definitions */
typedef uint32_t VAL;
typedef uint32_t ID;
typedef char*    STR;
typedef double  DBL;

enum NODE_FLAGS
{
  NFLAG_NONE,
  NFLAG_NODE
};

enum CLASS_FLAGS
{
  CF_NIL,
  CF_BASE,
  CF_CLASS,
  CF_STRING,
  CF_NUMBER
};

// Base ruby data reqd by descendents
typedef struct rb_base
{
  uint32_t classname;
  uint32_t flags;
} RBBase;

typedef struct rb_class
{
  struct rb_base base;
  struct symbol_table mth_table; // method symbol table
  struct symbol_table iv_table;  // instance var table

} RBClass;

typedef struct rb_string
{
  struct rb_base base;
  uint32_t length;
  char* ptr;
} RBString;

typedef struct rb_numeric
{
  struct rb_base base;
  uint32_t value;
} RBNumber;

void set_filename(char *filename);

#endif
