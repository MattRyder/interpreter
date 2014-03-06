/* node.h */

#ifndef NODE_H
#define NODE_H

#include "rbcore.h"

typedef struct Node
{
  uint32 flags;

  union 
  {
    struct Node *node;
    //ID id; possibly unused
    //ID *table; unused
    VAL val;
    VAL (*func)(); 
  } Value1;

  union
  {
    struct Node *node;
    //ID id;
    //VAL val;
    int arg_length;
  } Value2;

  union
  {
    struct Node *node;
    //ID id;
    //VAL val;
    //struct *gvar_entry;
    //int state; unused in mruby, possibly.
    int count;
  } Value3;
} NODE;

/* Node types for the AST */
enum NODETYPES {
  NODE_ALIAS,         /* alias method as...              */
  NODE_AND,           /* and                             */
  NODE_ARGS,          /* method arguments                */
  NODE_ARRAY,         /* [] w/ elements                  */
  NODE_BEGIN,         /* begin                           */
  NODE_BLOCK,         /* rb block                        */
  NODE_BACKREF,       /* regex backreference             */
  NODE_CASE,          /* case statement                  */
  NODE_CALL,          /* method call                     */
  NODE_CLASS,         /* class def                       */
  NODE_COLONS,        /* constant lookup from class      */
  NODE_CONSTNAME,     /* constant name                   */
  NODE_CONSTREF,      /* class/const ref. placeholder    */
  NODE_CVAR,          /* const var retrival              */
  NODE_DASGN,         /* dynamic var assign              */
  NODE_DVAR,          /* dynamic var retrival            */
  NODE_DEFINED,       /* the defined? keyword            */
  NODE_DEFINITION,    /* a method definition             */
  NODE_DEFSINGLETON,  /* a singleton method definition   */
  NODE_DREGEX,        /* regex w/ interpolation          */
  NODE_DREGEX_ONCE,   /* as above, but one-shot          */
  NODE_DSTRING,       /* string with interpolation       */
  NODE_DXSTRING,      /* backtick str with interpolation */
  NODE_ENSURE,        /* ensure                          */
  NODE_EVSTR,         /* a string interpolation          */
  NODE_EXECSTR,       /* %x string                       */
  NODE_FLIP2,         /* exp-exp flipflop inclusive      */
  NODE_FLIP3,         /* exp-exp flipflop exclusive      */
  NODE_GASGN,         /* global var assign               */
  NODE_GVAR,          /* global var retrival             */
  NODE_HASH,          /* {} hash                         */
  NODE_IF,            /* if                              */
  NODE_IASGN,         /* instance var assign             */
  NODE_ISET,          /* instance var writer             */
  NODE_ITER,          /* 'do' iteration                  */
  NODE_IVAR,          /* instance var retrival           */
  NODE_LASGN,         /* local var assign                */
  NODE_LITERAL,       /* literal object                  */
  NODE_LVAR,          /* local var retrival              */
  NODE_FOR,           /* for                             */
  NODE_MODULE,        /* module keyword                  */
  NODE_MASGN,         /* multiple assign                 */
  NODE_MATCHREF,      /* regex match                     */
  NODE_NEWLINE,       /* represents a newline character  */
  NODE_NOT,           /* not                             */
  NODE_NIL,           /* nil                             */
  NODE_NREF,          /* Gets an nth matched term        */
  NODE_OR,            /* or                              */
  NODE_OPT_N,         /* -n/-p flag                      */
  NODE_OPASGN1,       /* recv[i] += val asgn             */
  NODE_OPASGN2,       /* foo.bar += val asgn             */
  NODE_RANGE2,        /* begin-to-end inclusive          */
  NODE_RANGE3,        /* begin-to-end exclusive          */
  NODE_RESBODY,       /* rescue block                    */
  NODE_RESCUE,        /* rescue statement                */
  NODE_RETURN,        /* return                          */
  NODE_SINCLASS,      /* singleton class def             */
  NODE_SELF,          /* self reference                  */
  NODE_STRING,        /* string data type                */
  NODE_SUPER,         /* super keyword                   */
  NODE_UNDEFINE,      /* undefines a method              */
  NODE_UNTIL,         /* until keyword                   */
  NODE_WHEN,          /* when keyword                    */
  NODE_VALIAS,        /* variable aliasing               */
  NODE_VCALL,         /* call w/ runtime reciever        */
  NODE_WHILE,         /* while keyword                   */
  NODE_YIELD,         /* yield keyword                   */
  NODE_ZARRAY,        /* [] without elements             */
  NODE_ZSUPER         /* super w/o keywords              */
};

#endif
