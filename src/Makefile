BUILD_DIR = ../build
EXE 			= interpreter

CC   			= clang
CFLAGS 		= -c -o $(BUILD_DIR)/$@
LDFLAGS   = -o $(BUILD_DIR)/$(EXE) # "linker flags", yeah

OBJS 			= parser.tab.o lex.yy.o rbcore.o gc.o vm.o main.o

.PHONY: all clean

all: interpreter

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser: lex.yy.c parser.tab.c parser.tab.h
	$(CC) lex.yy.c parser.tab.c -lfl -ly $(CFLAGS)

.c.o:
	$(CC) $(CFLAGS) $<  

interpreter: $(OBJS)
	$(CC) $(LDFLAGS) $(foreach OBJECT, $(OBJS), $(BUILD_DIR)/$(OBJECT))

clean:
	rm -rfv $(BUILD_DIR)/$(EXE) lex.yy.c parser.tab.* $(BUILD_DIR)/*.o
