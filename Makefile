SRCS = main.c helpers.c parser.c lexer.c
CC = gcc

test: all
	cat sample.asm | ./parser

# if we compile them all together, we should get out what we want!
all: $(SRCS) helpers.h
	$(CC) $(SRCS) -o parser

# to regenerate the lexer, we call `flex` on it, which will
# create the lexer.c and lexer.h files
lexer.c: lexer.l helpers.h
	flex lexer.l

# to regenerate the parser, we call `bison` on it, which will
# create the bison.c and bison.h files
parser.c: parser.y lexer.l helpers.h
	bison parser.y

clean:
	rm -rf *.o lexer.c lexer.h parser.c parser.h parser
