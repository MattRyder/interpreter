#include <stdio.h>
#include "vm.h"

int main(int argc, char **argv)
{
  printf("Rubyx v1.0\n");

  vm_init();
  vm_opts(argc, argv);



  printf("Done!\n");
  return 0;
}
