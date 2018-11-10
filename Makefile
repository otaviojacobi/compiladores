.PHONY: clean test sample

CFLAGS = -lfl -Iinclude -g
all:
	bison -d parser.y --report-file=parser.output --verbose
	flex scanner.l
	gcc main.c src/*.c parser.tab.c lex.yy.c -o etapa5 $(CFLAGS)

clean:
	rm -f etapa5
	rm -f lex.yy.c
	rm -f parser.tab.c
	rm -f parser.tab.h
	rm -f sample
	rm -f parser.output
	rm -f test/*_diff.txt
	rm -f test/*_out.txt
	rm -f test/*_out2.txt
	rm -f test/*_valgrind.txt
	rm -f test/*_warning_diff.txt
	rm -f test/*_mem.txt
	rm -f test/*_iloc.txt
	rm -f vgcore.*
	find . -type f -name '*.log' -delete

sample:
	gcc tree_sample.c src/*.c -o sample -Iinclude
test:
	./test.sh