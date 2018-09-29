#ifndef __VALOR_LEXICO_H
#define __VALOR_LEXICO_H

typedef enum {
  RESERVED_WORD,
  SPECIAL_CHAR,
  COMPOSED_OP,
  IDENTIFICATOR,
  LITERAL_INT,
  LITERAL_FLOAT,
  LITERAL_BOOL,
  LITERAL_CHAR,
  LITERAL_STRING
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

#endif