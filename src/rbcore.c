/* ruby core logic */

#include "node.h"

int base_argc;
char **base_argv;

char *script_filename;

void parse_argv(int argc, char **argv)
{
  NODE *tree;
  base_argc = argc;
  base_argv = argv;

  printf("[DBG] Arg count: %d\n", argc);

  set_filename(argv[1]);
  printf("[DBG] set filename as: %s\n", argv[1]);

  // TODO: parse any params here
  tree = parse_file(script_filename);

  printf("TREE: %\d %c %d = 95\n", (NODE*)tree->Value1.node,
      tree->Value2.node, tree->Value3.node);
}

// Sets the filename of the Ruby program
// we're reading and evaluating
void set_filename(char *filename)
{
  if(filename)
    script_filename = filename;
}
