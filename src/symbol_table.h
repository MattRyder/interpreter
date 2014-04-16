/* Symbol Table - symbol_table.h */
#include "rbcore.h"
#include "gc.h"

// For when no size is given
#define ST_DEFAULT_SIZE 8
#define ST_HASH_MOD     3

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

SYMBOL_TABLE* create_stable(uint32_t init_size);
void delete_stable(SYMBOL_TABLE* sym_table);
uint32_t insert_entry(SYMBOL_TABLE *sym_table, char* key, char* value);
ST_ENTRY* find_entry(SYMBOL_TABLE* sym_table, char* key, uint64_t hash_val);
uint32_t delete_entry();

uint64_t hash(register char* keyvalue, uint32_t table_max);
uint64_t lookup_value(SYMBOL_TABLE* sym_table, char* key, char* value);

