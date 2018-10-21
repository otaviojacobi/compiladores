#ifndef __SCOPE_STACK_H
#define __SCOPE_STACK_H

#include "symbol_table.h"
#include "stack.h"


symbol_table_t* find_item(stack_node_t* tables, char *key);
int add_item(stack_node_t* tables, char *key, symbol_table_item_t *item);
void push(stack_node_t** stack, symbol_table_t** value);
void pop(stack_node_t** s);
void new_scope(stack_node_t **tables, symbol_table_t** new_scope);
int update_item(stack_node_t* tables, char *key, symbol_table_item_t *item);


#endif