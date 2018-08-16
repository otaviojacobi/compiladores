all:
	flex scanner.l
	gcc main.c lex.yy.c -o etapa1 -lfl

clean:
	rm -f etapa1
	rm -f lex.yy.c

test:
	bash test.sh