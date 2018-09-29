.PHONY: clean test

CFLAGS = -lfl -Iinclude -g
all:
	bison -d parser.y --report-file=parser.output --verbose
	flex scanner.l
	gcc main.c src/*.c parser.tab.c lex.yy.c -o etapa3 $(CFLAGS)

clean:
	rm -f etapa3
	rm -f lex.yy.c
	rm -f parser.tab.c
	rm -f parser.tab.h
	rm -f sample
	find . -type f -name '*.log' -delete

sample:
	gcc tree_sample.c src/utils.c src/tree.c src/queue.c src/stack.c -o sample -Iinclude
test:
	./test.sh