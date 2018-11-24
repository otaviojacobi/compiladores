#include "scope_stack.h"

symbol_table_t* find_item(stack_node_t* tables, char *key){
  symbol_table_t** temp = (symbol_table_t**) tables->value;
  if(tables->next == NULL){
    return _find_item(temp, key);
  }else{
    symbol_table_t* return_value = _find_item(temp, key);
    if(return_value == NULL)
      return find_item(tables->next, key);
    else
      return return_value;
  }
}

int add_item(stack_node_t* tables, char *key, symbol_table_item_t *item){
  return _add_item(tables->value, key, item);
}

void push(stack_node_t** stack, symbol_table_t** value){
  stack_node_t* s = *stack;
  stack_node_t* temp = create_stack_node(value);
  temp->next = s; // if s is NULL it wont be a problem as it will just keep poiting to a null ref
  *stack = temp;
}

void pop(stack_node_t** s, int clear){
  stack_node_t* temp = *s;
  *s = temp->next;
  //printf("inner table:\n");  // #debug
  //print_table(temp->value);  // #debug
  if(clear == 1){
    clear_table(temp->value);
    free(temp);
  }
}

void new_scope(stack_node_t **tables, symbol_table_t** new_scope){ // just a more function-descriptive name for push
  push(tables, new_scope);
}

int update_item(stack_node_t* tables, char *key, symbol_table_item_t *item){
  if(tables->next == NULL)
    return _update_item(tables->value, key, item);
  else{
    int return_value = _update_item(tables->value, key, item);
    if(return_value==-1)
      return update_item(tables->next, key, item);
    else 
      return return_value;
  }
}