/* symbol table - symbol_table.c */

#include "symbol_table.h"

SYMBOL_TABLE* create_stable(uint32_t init_size)
{
  SYMBOL_TABLE* new_stable;
  
  if(init_size < ST_DEFAULT_SIZE)
    init_size = ST_DEFAULT_SIZE;

  new_stable = rballoc(sizeof(SYMBOL_TABLE));
  new_stable->entry_size = init_size;
  new_stable->entry_count = 0;
  new_stable->entries = rballoc_multi(sizeof(ST_ENTRY), init_size);

  return new_stable;
}

void delete_stable(SYMBOL_TABLE* sym_table)
{
  ST_ENTRY *entry, *next_entry;
  for(int i = 0; i < sym_table->entry_count; i++)
  {
    entry = &sym_table->entries[i];
    
    //clear every link in the entry:
    while(entry->next_entry != 0)
    {
      next_entry = entry->next_entry;
      free(entry);
      entry = next_entry;
    }
  }

  // free the entry ptr
  free(sym_table->entries);
  free(sym_table);
}

uint32_t insert_entry(SYMBOL_TABLE* sym_table, char* key, char* value)
{
  uint64_t hashed_value = hash(key, sym_table->entry_count);
  ST_ENTRY* last_entry = find_entry(sym_table, key, hashed_value);

  if(last_entry != 0)
  {
    // insert entry into table:
    ST_ENTRY* new_entry = rballoc(sizeof(ST_ENTRY));
    new_entry->key = key;
    new_entry->value = value;
    new_entry->next_entry = &sym_table->entries[hashed_value];

    sym_table->entries[hashed_value] = *new_entry;
    sym_table->entry_count++;
    return 0;
  }
  
  // Add it to the last entry;
  last_entry->value = value;
  return 1;
}

uint64_t lookup_value(SYMBOL_TABLE* sym_table, char* key, char* value)
{
  uint64_t hashed_value = hash(key, sym_table->entry_count);
  ST_ENTRY* entry = find_entry(sym_table, key, hashed_value);
  
  if(entry != 0)
  {
    if(value != 0)
      *value = entry->value;
    
    return 1;
  }
  return 0; // failed to lookup val
}

ST_ENTRY* find_entry(SYMBOL_TABLE* sym_table, char* key, uint64_t hash_val)
{
  ST_ENTRY* entry = &sym_table->entries[hash_val];

  while(entry != 0 && !strcmp(entry->key, key))
    entry = entry->next_entry;
  
  return entry;
}

// A Fowler-Noll-Vo hash function
// returns a value in the hash table (as given by table_max)
uint64_t hash(register char* keyvalue, uint32_t table_max)
{
  // foreach char in string
  // hash_val = hash_val * prime + char

  register uint32_t hash_val = 0;
  register uint32_t str_char = 0;

  while((str_char = *keyvalue++) != '\0') {
    hash_val = hash_val * 701;
    hash_val ^= str_char;
  }

  // ensure absolute value
  if(hash_val < 0)
    hash_val = -hash_val;

  return hash_val % table_max;
}
