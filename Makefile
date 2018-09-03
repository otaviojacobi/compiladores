.PHONY: clean test
all:
	bison -d parser.y --report-file=parser.output --verbose
	flex scanner.l
	gcc main.c parser.tab.c lex.yy.c -o etapa2 -lfl

clean:
	rm -f etapa2
	rm -f lex.yy.c
	rm -f parser.tab.c
	rm -f parser.tab.h
	find . -type f -name '*.log' -delete

test:
	./test.sh