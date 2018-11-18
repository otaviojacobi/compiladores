#ifndef __SYMBOL_TABLE_H
#define __SYMBOL_TABLE_H

#include <string.h>
#include "uthash.h"
#include "valor_lexico.h"
#include "natureza.h"

typedef struct arg_list {

    token_type_t type;
    char *field_name;
    int protec_level; //only in case of new type declaration !!don't worry about null printing
    struct arg_list *next;

} arg_list_t;


typedef struct symbol_table_item {

    int line;
    int nature;
    token_type_t type;
    int type_size;
    arg_list_t *arg_list;
    token_value_t value;
    token_value_t init_value;
    int var_offset;
    int is_const;
    int is_static;
    int is_vector;
    int is_global;
    int func_label;
} symbol_table_item_t;

typedef struct symbol_table {

    char key[30];
    symbol_table_item_t *item;
    int register_or_label;
    UT_hash_handle hh;

} symbol_table_t;

int _add_item(symbol_table_t **SYMBOL_TABLE, char *key, symbol_table_item_t *item);
symbol_table_t *_find_item(symbol_table_t **SYMBOL_TABLE, char *key);
int remove_item(symbol_table_t **SYMBOL_TABLE, char *key);
int clear_table(symbol_table_t **SYMBOL_TABLE);
int _update_item(symbol_table_t **SYMBOL_TABLE, char *key, symbol_table_item_t *item);
void print_table(symbol_table_t **SYMBOL_TABLE);

void create_table_item(symbol_table_item_t* item, 
                       int line, 
                       int nature,
                       token_type_t type,
                       int type_size,
                       arg_list_t *arg_list,
                       token_value_t value,
                       int is_const,
                       int is_static,
                       int is_vector );


#endif