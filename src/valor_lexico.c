#include "valor_lexico.h"

void print_valor_lexico(valor_lexico_t *valor_lexico) {
  switch(valor_lexico->type) {

    case AST_TYPE_IDENTIFICATOR:
      printf("Ident: %s\n", valor_lexico->value.stringValue);
      break;

    case AST_TYPE_LITERAL_INT: 
      printf("LitInt: %d\n", valor_lexico->value.intValue);
      break;
    
    case AST_TYPE_LITERAL_FLOAT: 
      printf("LitFloat: %f\n", valor_lexico->value.floatValue);
      break;
    
    case AST_TYPE_LITERAL_BOOL:
      //char *fancy_bool = boolToStr(valor_lexico->value.boolValue);
      printf("LitBool: %s\n", valor_lexico->value.boolValue);
      //free(fancy_bool);
      break;

    case AST_TYPE_LITERAL_CHAR:
      printf("LitChar: %c\n", valor_lexico->value.charValue);
      break;

    case AST_TYPE_LITERAL_STRING: 
      printf("LitStr: %s\n", valor_lexico->value.stringValue);
      break;

    default: print_type(valor_lexico->type);
  }
}

valor_lexico_t* __construct_valor_lexico(int i, token_type_t type, char* value) {
  valor_lexico_t* vl = (valor_lexico_t*)malloc(sizeof(valor_lexico_t));
  vl->line = i;
  vl->type = type;

  switch(type) {
    case AST_TYPE_LITERAL_INT: vl->value.intValue = atoi(value);
      break;
    case AST_TYPE_LITERAL_FLOAT: vl->value.floatValue = atof(value);
      break;
    case AST_TYPE_LITERAL_BOOL: vl->value.boolValue = strToBool(value);
      break;
    case AST_TYPE_LITERAL_CHAR: vl->value.charValue = value[1];
      break;
    case AST_TYPE_IDENTIFICATOR:
    case AST_TYPE_LITERAL_STRING: vl->value.stringValue = value;
      break;
  }

  return vl;
}

void print_type(token_type_t type) {
  
  switch(type) {
    case AST_TYPE_IDENTIFICATOR: printf("AST_TYPE_IDENTIFICATOR\n"); break;
    case AST_TYPE_LITERAL_INT: printf("AST_TYPE_LITERAL_INT\n"); break;
    case AST_TYPE_LITERAL_FLOAT: printf("AST_TYPE_LITERAL_FLOAT\n"); break;
    case AST_TYPE_LITERAL_BOOL: printf("AST_TYPE_LITERAL_BOOL\n"); break;
    case AST_TYPE_LITERAL_CHAR: printf("AST_TYPE_LITERAL_CHAR\n"); break;
    case AST_TYPE_LITERAL_STRING: printf("AST_TYPE_LITERAL_STRING\n"); break;

    //utils
    case AST_TYPE_PROGRAM_START: printf("AST_TYPE_PROGRAM_START\n"); break;
    case AST_TYPE_FUNCTION: printf("AST_TYPE_FUNCTION\n"); break;

    //commmand
    case AST_TYPE_WHILE_DO: printf("AST_TYPE_WHILE_DO\n"); break;
    case AST_TYPE_RETURN: printf("AST_TYPE_RETURN\n"); break;
    case AST_TYPE_IF_ELSE: printf("AST_TYPE_IF_ELSE\n"); break;
    case AST_TYPE_ATTRIBUTION: printf("AST_TYPE_ATTRIBUTION\n"); break;
    case AST_TYPE_CASE: printf("AST_TYPE_CASE\n"); break;

    //logic ops
    case AST_TYPE_LS: printf("AST_TYPE_LS\n"); break;
    case AST_TYPE_LE: printf("AST_TYPE_LE\n"); break;
    case AST_TYPE_GR: printf("AST_TYPE_GR\n"); break;
    case AST_TYPE_GE: printf("AST_TYPE_GE\n"); break;
    case AST_TYPE_EQ: printf("AST_TYPE_EQ\n"); break;
    case AST_TYPE_NE: printf("AST_TYPE_NE\n"); break;
    case AST_TYPE_AND: printf("AST_TYPE_AND\n"); break;
    case AST_TYPE_OR: printf("AST_TYPE_OR\n"); break;
    case AST_TYPE_SL: printf("AST_TYPE_SL\n"); break;
    case AST_TYPE_SR: printf("AST_TYPE_SR\n"); break;

    //aritmetic ops
    case AST_TYPE_ADD: printf("AST_TYPE_ADD\n"); break;
    case AST_TYPE_SUB: printf("AST_TYPE_SUB\n"); break;
    case AST_TYPE_MUL: printf("AST_TYPE_MUL\n"); break;
    case AST_TYPE_DIV: printf("AST_TYPE_DIV\n"); break;
    default: "ESQUECEU DE INSERIR BOCA ABERTA\n";
  }
}