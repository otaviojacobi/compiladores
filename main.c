/*
Função principal para realização da E3.

Este arquivo não pode ser modificado.
*/
#include <stdio.h>
#include "parser.tab.h" //arquivo gerado com bison -d parser.y
#include "tree.h"
#include "scope_stack.h"

void *arvore = NULL;
symbol_table_t *outer_table = NULL;
stack_node_t *tables = NULL;

int main (int argc, char **argv)
{
  push(&tables, &outer_table);
  int ret = yyparse();
  //print_table(&outer_table);
  descompila (arvore);
  libera(arvore);
  clear_table(&outer_table);

  arvore = NULL;
  return ret;
}