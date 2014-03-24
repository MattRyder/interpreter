/* ruby core logic */

#include "rbcore.h"
#include "node.h"

int base_argc;
char **base_argv;

char *script_filename;

NODE* parse_file(char* filename);

void parse_argv(int argc, char **argv)
{
  NODE *tree;
  base_argc = argc;
  base_argv = argv;

  set_filename(argv[1]);

  // TODO: parse any params here
  tree = (NODE*)parse_file(script_filename);

  //printf("%d %c %d", tree->Value1.node, tree->Value2.node, tree->Value3.node);
}

// Sets the filename of the Ruby program
// we're reading and evaluating
void set_filename(char *filename)
{
  if(filename)
    script_filename = filename;
}
