/* gc.c - garbage collector */
#include "gc.h"

// the list that holds all objects alloc'd
RBValue* object_list = 0;

VAL *stack_start;
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
  VAL start;
  stack_start = &start;
}

void init_heap()
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
    printf("[INFO] Free space available in object_list\n");
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

void add_heaps()
{
  RBValue *ptr, *ptr_end;

  // realloc if we've hit 100% heap usage
  if(heap_used == heap_length)
  {
    heap_length += HEAP_INCREMENT;
    if(heap_used > 0)
    {
      heap_ptr = realloc(heap_ptr, sizeof(RBValue) * heap_length);
    }
    else 
    {
      heap_ptr = malloc(sizeof(RBValue) * heap_length);
    }

    if(heap_ptr == 0)
    {
      printf("[CRITICAL] Failed to allocate heap!\n");
      return;
    }
  }

  ptr = heap_ptr[heap_used++] = malloc(sizeof(RBValue) * HEAP_SLOTS);
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

