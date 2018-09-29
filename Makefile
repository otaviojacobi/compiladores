.PHONY: clean test

CFLAGS = -lfl -Iinclude -g
all:
	bison -d parser.y --report-file=parser.output --verbose
	flex scanner.l
	gcc main.c src/utils.c parser.tab.c lex.yy.c -o etapa3 $(CFLAGS)

clean:
	rm -f etapa3
	rm -f lex.yy.c
	rm -f parser.tab.c
	rm -f parser.tab.h
	find . -type f -name '*.log' -delete

test:
	./test.sh