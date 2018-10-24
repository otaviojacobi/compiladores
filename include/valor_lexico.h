#ifndef __VALOR_LEXICO_H
#define __VALOR_LEXICO_H

#include <stdio.h>
#include "utils.h"

typedef enum {

  AST_TYPE_NULL,
  AST_TYPE_INT,
  AST_TYPE_FLOAT,
  AST_TYPE_BOOL,
  AST_TYPE_CHAR,
  AST_TYPE_STRING,
  AST_TYPE_FUNCTION_HEAD,
  AST_TYPE_PARAM,

  AST_TYPE_IDENTIFICATOR,
  AST_TYPE_LITERAL_INT,
  AST_TYPE_LITERAL_FLOAT,
  AST_TYPE_LITERAL_BOOL,
  AST_TYPE_LITERAL_CHAR,
  AST_TYPE_LITERAL_STRING,

  AST_TYPE_STATIC,
  AST_TYPE_CONST,

  AST_TYPE_COMMAND_BLOCK,
  AST_TYPE_COMMAND,
  AST_TYPE_FOR_COMMAND,
  AST_TYPE_EXPRESSION_LIST,
  AST_TYPE_CLASS,
  AST_TYPE_CLASS_FIELD,
  AST_TYPE_CLASS_FIELD_LIST,
  AST_TYPE_PROTECTION_PRIVATE,
  AST_TYPE_PROTECTION_PUBLIC,
  AST_TYPE_PROTECTION_PROTECTED,
  AST_TYPE_PARAM_LIST,

  AST_TYPE_GLOBAL_VAR,


  //utils
  AST_TYPE_PROGRAM_START,
  AST_TYPE_FUNCTION,
  AST_TYPE_FUNCTION_CALL,
  AST_TYPE_VECTOR,
  AST_TYPE_OBJECT,
  AST_TYPE_INPUT,
  AST_TYPE_OUTPUT,

  //commmand
  AST_TYPE_RETURN,
  AST_TYPE_BREAK,
  AST_TYPE_CONTINUE,
  AST_TYPE_IF_ELSE,
  AST_TYPE_ATTRIBUTION,
  AST_TYPE_CASE,
  AST_TYPE_DECLR,
  AST_TYPE_TERNARY,
  AST_TYPE_FOR,
  AST_TYPE_FOREACH,
  AST_TYPE_WHILE_DO,
  AST_TYPE_DO_WHILE,
  AST_TYPE_SWITCH,

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
  AST_TYPE_BW_OR,
  AST_TYPE_BW_AND,
  AST_TYPE_BW_XOR,
  AST_TYPE_NEGATE,

  // unary stuff
  AST_TYPE_ADDRESS,
  AST_TYPE_POINTER,
  AST_TYPE_QUESTION_MARK,
  AST_TYPE_HASHTAG,

  //aritmetic ops
  AST_TYPE_ADD,
  AST_TYPE_SUB,
  AST_TYPE_MUL,
  AST_TYPE_DIV,
  AST_TYPE_REST,
  AST_TYPE_NEGATIVE,

  // pipe and weird stuff
  AST_TYPE_FOWARD_PIPE,
  AST_TYPE_BASH_PIPE,
  AST_TYPE_DOT

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
