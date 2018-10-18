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

symbol_table_t *find_item(symbol_table_t **SYMBOL_TABLE, char *key) {

  symbol_table_t *st;
  HASH_FIND_STR(*SYMBOL_TABLE, key, st);

  return st;
}

void _free_symbol_table_line(symbol_table_t *st) {

  _arg_list_t *aux;
  if(st->item) {

    if(st->item->nature == NATUREZA_LITERAL_STRING) {
      free(st->item->value.stringValue);
    }

    if(st->item->nature == NATUREZA_FUNCAO && st->item->type == AST_TYPE_FUNCTION) {
      while(st->item->arg_list != NULL) {
        aux = st->item->arg_list;
        st->item->arg_list = st->item->arg_list->next;
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