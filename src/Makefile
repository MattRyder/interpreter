CC  	 		= gcc
PARSEGEN  = bison

CFLAGS 		= -o $(BUILD_DIR)/$(PARSER)
PGFLAGS 	= --language=c++

BUILD_DIR = ../build
PARSER 		= interpreter

.PHONY: clean cleanall

parser.tab.cc: parser.y
	$(PARSEGEN) $(PGFLAGS) $<

parser: parser.tab.cc
	$(CC) $(CFLAGS) $<

clean:
	rm -rfv $(BUILD_DIR)/*.o
