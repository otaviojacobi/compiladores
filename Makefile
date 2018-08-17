.PHONY: clean test
all:
	flex scanner.l
	gcc main.c lex.yy.c -o etapa1 -lfl

clean:
	rm -f etapa1
	rm -f lex.yy.c
	find . -type f -name '*.log' -delete

test:
	./test.sh