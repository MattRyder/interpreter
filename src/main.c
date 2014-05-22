#include <stdio.h>
#include "vm.h"

int main(int argc, char **argv)
{
  printf("Rubyx v1.0\n");

  vm_init();
  vm_opts(argc, argv);
  vm_exec();

  return 0;
}
