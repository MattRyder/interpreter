BUILD_DIR = .
EXE 			= interpreter

CC   			= clang
CFLAGS 		= -c -lfl -ly
LDFLAGS   = -o $(BUILD_DIR)/$(EXE) # "linker flags", yeah

OBJS 			= parser.tab.o lex.yy.o gc.o

.PHONY: all clean

all: interpreter

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser: lex.yy.c parser.tab.c parser.tab.h
	$(CC) lex.yy.c parser.tab.c $(CFLAGS)

interpreter: $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS)

clean:
	rm -rfv $(BUILD_DIR)/$(EXE) lex.yy.c parser.tab.* stack.hh *.o
