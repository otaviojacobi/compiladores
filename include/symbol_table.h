#ifndef __SYMBOL_TABLE_H
#define __SYMBOL_TABLE_H

#include <string.h>
#include "uthash.h"
#include "valor_lexico.h"
#include "natureza.h"

typedef struct _arg_list {

    token_type_t type;
    struct _arg_list *next;

} _arg_list_t;


typedef struct symbol_table_item {

    int line;
    int nature;
    token_type_t type;
    int type_size;
    _arg_list_t *arg_list;
    token_value_t value;
    int is_const;
    int is_static;
    int is_vector;

} symbol_table_item_t;

typedef struct symbol_table {

    char key[200];
    symbol_table_item_t *item;
    UT_hash_handle hh;

} symbol_table_t;

int add_item(symbol_table_t **SYMBOL_TABLE, char *key, symbol_table_item_t *item);
symbol_table_t *find_item(symbol_table_t **SYMBOL_TABLE, char *key);
int remove_item(symbol_table_t **SYMBOL_TABLE, char *key);
int clear_table(symbol_table_t **SYMBOL_TABLE);
int update_item(symbol_table_t **SYMBOL_TABLE, char *key, symbol_table_item_t *item);
void print_table(symbol_table_t **SYMBOL_TABLE);

void create_table_item(symbol_table_item_t* item, 
                       int line, 
                       int nature,
                       token_type_t type,
                       int type_size,
                       _arg_list_t *arg_list,
                       token_value_t value,
                       int is_const,
                       int is_static,
                       int is_vector );


#endif