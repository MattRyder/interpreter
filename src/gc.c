/* gc.c - garbage collector */
#include "gc.h"

// the list that holds all objects alloc'd
RBValue* object_list = 0;

VAL*   stack_start;
static RBValue** heap_ptr;

static int heap_length = 0;
static int heap_used = 0;

// Lowest and highest bounds of heap memory
static RBValue* mem_low;
static RBValue* mem_top;

// GC Malloc limit:
#define GC_ALLOC_MAX 100000
static uint64_t allocated_bytes = 0;

void init_stack()
{
  stack_start = malloc(sizeof(VAL));
}

void init_gc()
{
  init_stack();
  add_heaps();
}

RBBase* create_obj()
{
  RBBase* new_obj;

  // check if we've got heap space
  if(object_list)
  {
    new_obj = (RBBase*)object_list;
    object_list = object_list->type.free.nextptr;
    return new_obj;
  } 
  else
  {
    printf("[INFO] Appending heap!\n");
    // TODO: replace this for a gc sweep
    add_heaps();
    return create_obj();
  }
}

RBString* create_string(char* node_str)
{
  RBString* str = (RBString*)create_obj();
  str->base.flags = CF_STRING;
  
  str->length = strlen(node_str);
  str->ptr = rballoc_multi(sizeof(char), str->length);

  if(str->ptr)
    memcpy(str->ptr, node_str, str->length);

  // null the string
  str->ptr[str->length] = '\0';
  return str;
}

RBNumber* create_number(uint32_t prim_num)
{
  RBNumber* num = (RBNumber*)create_obj();
  num->base.flags = CF_NUMBER;

  num->value = prim_num;
  return num;
}

void add_heaps()
{
  RBValue *ptr, *ptr_end;

  // realloc if we've hit 100% heap usage
  if(heap_used == heap_length)
  {
    heap_length += HEAP_INCREMENT;
    if(heap_used > 0)
    {
      heap_ptr = (RBValue**)realloc(heap_ptr, sizeof(RBValue) * heap_length);
    }
    else 
    {
      heap_ptr = (RBValue**)malloc(sizeof(RBValue) * heap_length);
    }

    if(heap_ptr == 0)
    {
      printf("[CRITICAL] Failed to allocate heap!\n");
      return;
    }
  }
  
  ptr = heap_ptr[heap_used++] = (RBValue*)malloc((2 * sizeof(RBValue)) * HEAP_SLOTS );
  ptr_end = ptr + HEAP_SLOTS;
  if(heap_ptr == 0)
  {
    printf("[CRITICAL] Failed to allocate heap!\n");
    return;
  }

  // set memory bounds
  if(mem_low == 0 || mem_low > ptr)
    mem_low = ptr;

  if(mem_top < ptr_end)
    mem_top = ptr_end;

  while(ptr < ptr_end)
  {
    ptr->type.free.flags = 0;
    ptr->type.free.nextptr = object_list;
    object_list = ptr;
    ptr++;
  }

}

/* MEMORY ALLOCATION */
void* rballoc(uint64_t size)
{
  void* ptr;
  size = (size) ? size : 1;

  allocated_bytes += size;
  if(allocated_bytes > GC_ALLOC_MAX)
    printf("HIT MAX, PLEASE IMPLEMENT GC!\n"); // go collect gc

  ptr = malloc(size);
  if(!ptr)
    printf("[CRITICAL] Failed to alloc memory!\n");

  return ptr;
}

// Allocate mem for <type> * <num>
void* rballoc_multi(size_t type, uint64_t num)
{
  void* ptr;
  uint64_t req_malloc_size = type * num;

  ptr = rballoc(req_malloc_size);

  if(!ptr)
    printf("[CRITICAL] Failed to rballoc_multi!\n");
  
  return ptr;
}


