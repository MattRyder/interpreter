CFLAGS 		= -o $(BUILD_DIR)/$(EXE) -lfl -ly

BUILD_DIR = .
EXE 			= interpreter

.PHONY: all clean

all: parser

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y


lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser: lex.yy.c parser.tab.c parser.tab.h
	cc parser.tab.c lex.yy.c $(CFLAGS)

clean:
	rm -rfv $(BUILD_DIR)/$(EXE) lex.yy.c parser.tab.h parser.tab.c
