/* ruby core - rbcore.h */

#ifndef RBCORE_H
#define RBCORE_H

#include <stdint.h>

// Define a value for when an op return nil by design (nothing else to do etc)
#define RBNIL 0x5 // uncommon enough return code?

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


// Symbol tables are a core part of the interpreter:
typedef struct st_entry {
  char* key;
  char* value;
  struct st_entry* next_entry;
} ST_ENTRY;

typedef struct symbol_table {
  uint32_t entry_count;
  uint32_t entry_size;
  struct st_entry* entries;
} SYMBOL_TABLE;



// Base ruby data reqd by descendents
typedef struct rb_base
{
  uint32_t classname;
  uint32_t flags;
} RBBase;

typedef struct rb_class
{
  struct rb_base base;
  struct symbol_table mtd_table; // method symbol table
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
