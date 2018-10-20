#include "symbol_table.h" 

int add_item(symbol_table_t **SYMBOL_TABLE, char *key, symbol_table_item_t *item) {

  symbol_table_t *aux = find_item(SYMBOL_TABLE, key);

  if(aux == NULL) {
    symbol_table_t *st = (symbol_table_t *)malloc(sizeof(symbol_table_t));
    strcpy(st->key, key);
    st->item = item;
    HASH_ADD_STR(*SYMBOL_TABLE, key, st);
    return 0;
  }
  return -1;

}

int update_item(symbol_table_t **SYMBOL_TABLE, char *key, symbol_table_item_t *item) {
  
  symbol_table_t *aux = find_item(SYMBOL_TABLE, key);

  if(aux != NULL) {
    remove_item(SYMBOL_TABLE, key);
    symbol_table_t *st = (symbol_table_t *)malloc(sizeof(symbol_table_t));
    strcpy(st->key, key);
    st->item = item;
    HASH_ADD_STR(*SYMBOL_TABLE, key, st);
    return 0;
  }
  return -1;

}

symbol_table_t *find_item(symbol_table_t **SYMBOL_TABLE, char *key) {

  symbol_table_t *st;
  HASH_FIND_STR(*SYMBOL_TABLE, key, st);

  return st;
}

void _free_symbol_table_line(symbol_table_t *st) {

  arg_list_t *aux;
  if(st->item) {

    if(st->item->nature == NATUREZA_LITERAL_STRING) {
      free(st->item->value.stringValue);
    }

    if((st->item->nature == NATUREZA_FUNCAO && st->item->type == AST_TYPE_FUNCTION) || st->item->nature == NATUREZA_CLASS){
      while(st->item->arg_list != NULL) {
        aux = st->item->arg_list;
        st->item->arg_list = st->item->arg_list->next;
        free(aux->field_name);
        free(aux);
      }
    }

    free(st->item);
  }

  free(st);
}


int remove_item(symbol_table_t **SYMBOL_TABLE, char *key) {
  symbol_table_t *st = find_item(SYMBOL_TABLE, key);
  HASH_DEL(*SYMBOL_TABLE, st);

  _free_symbol_table_line(st);

  return 0;
}

int clear_table(symbol_table_t **SYMBOL_TABLE) {
  symbol_table_t *current, *tmp;

  HASH_ITER(hh, *SYMBOL_TABLE, current, tmp) {
    HASH_DEL(*SYMBOL_TABLE,current);
    _free_symbol_table_line(current);
  }

  return 0;
}

void _print_item(symbol_table_t* t) {

  arg_list_t *aux = t->item->arg_list;

  printf("%s: ", t->key);
  printf("\t%d", t->item->line);
  printf("\t%d", t->item->nature);
  printf("\t%d", t->item->type);
  printf("\t%d\t", t->item->type_size);
  printf("\t%d\t", t->item->is_const);
  printf("\t%d\t", t->item->is_static);
  printf("\t%d", t->item->is_vector);

  if(t->item->arg_list) {
    printf("\tPARAMS: ");
    while(aux != NULL) {
      
      if(aux->protec_level== AST_TYPE_PROTECTION_PRIVATE)
        printf("private ");
      if(aux->protec_level== AST_TYPE_PROTECTION_PUBLIC)
        printf("public ");
      if(aux->protec_level== AST_TYPE_PROTECTION_PROTECTED)
        printf("protected ");

      printf("%s\t", aux->field_name);
      aux = aux->next;
    }
  }

  if(t->item->type == AST_TYPE_CLASS && (t->item->nature == NATUREZA_GLOBAL_VAR || t->item->nature == NATUREZA_IDENTIFICADOR)) {
    printf("\tTYPE NAME: %s", t->item->value.stringValue);
  }

  printf("\n");
  
}

void print_table(symbol_table_t **SYMBOL_TABLE) {
  symbol_table_t *current, *tmp;

  printf("KEY: line,\tnature,\ttype,\ttype_size,\tis_const,\tis_staic,\tis_vector\n");

  HASH_ITER(hh, *SYMBOL_TABLE, current, tmp) {
    _print_item(current);
  }
}

void create_table_item(symbol_table_item_t* item, 
                       int line, 
                       int nature,
                       token_type_t type,
                       int type_size,
                       arg_list_t *arg_list,
                       token_value_t value,
                       int is_const,
                       int is_static,
                       int is_vector ) {

    item->line = line;
    item->nature = nature;
    item->type = type;
    item->type_size = type_size;
    item->arg_list = arg_list;
    item->value = value;
    item->is_const = is_const;
    item->is_static = is_static;
    item->is_vector = is_vector;
}