#ifndef __VALOR_LEXICO_H
#define __VALOR_LEXICO_H

#include <stdio.h>
#include "utils.h"

typedef enum {

  AST_TYPE_IDENTIFICATOR,
  AST_TYPE_LITERAL_INT,
  AST_TYPE_LITERAL_FLOAT,
  AST_TYPE_LITERAL_BOOL,
  AST_TYPE_LITERAL_CHAR,
  AST_TYPE_LITERAL_STRING,

  //utils
  AST_TYPE_PROGRAM_START,
  AST_TYPE_FUNCTION,
  AST_TYPE_BLOCK,

  //commmand
  AST_TYPE_WHILE_DO,
  AST_TYPE_RETURN,
  AST_TYPE_IF_ELSE,
  AST_TYPE_ATTRIBUTION,
  AST_TYPE_CASE,

  //logic ops
  AST_TYPE_LS,
  AST_TYPE_LE,
  AST_TYPE_GR,
  AST_TYPE_GE,
  AST_TYPE_EQ,
  AST_TYPE_NE,
  AST_TYPE_AND,
  AST_TYPE_OR,
  AST_TYPE_SL,
  AST_TYPE_SR,

  //aritmetic ops
  AST_TYPE_ADD,
  AST_TYPE_SUB,
  AST_TYPE_MUL,
  AST_TYPE_DIV
  
} token_type_t;

typedef union token_value {
  int intValue;
  float floatValue;
  char charValue;
  int boolValue;
  char *stringValue;
} token_value_t;

typedef struct valor_lexico {
  int line;
  token_type_t type;
  token_value_t value;
} valor_lexico_t;

void print_valor_lexico(valor_lexico_t *valor_lexico);
void print_type(token_type_t type);
valor_lexico_t* __construct_valor_lexico(int i, token_type_t type, char* value);
#endif