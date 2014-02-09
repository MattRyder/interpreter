CC  	 		= gcc
BISON 	  = bison
FLEX 			= flex

CFLAGS 		= -o $(BUILD_DIR)/$(EXE) -ly -ll
BFLAGS 		= --language=c++

BUILD_DIR = ../build
EXE 			= interpreter

.PHONY: all clean

all: parser

lexer.y.cc: lexer.l

parser.tab.cc: parser.y
	$(BISON) $(BFLAGS) $<

parser: parser.tab.cc
	$(CC) $(CFLAGS) $<

clean:
	rm -rfv $(BUILD_DIR)/*.o
