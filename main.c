/*
Função principal para realização da E3.

Este arquivo não pode ser modificado.
*/
#include <stdio.h>
#include "parser.tab.h" //arquivo gerado com bison -d parser.y
#include "tree.h"

void *arvore = NULL;

int main (int argc, char **argv)
{
  int ret = yyparse();
  descompila (arvore);
  libera(arvore);

  arvore = NULL;
  return ret;
}