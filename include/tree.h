#ifndef __TREE_H
#define __TREE_H

#include <stdlib.h>
#include <stdio.h>
#include "utils.h"
#include "queue.h"
#include "stack.h"
#include "valor_lexico.h"

typedef struct tree_node {
    void* value;
    int childAmount;
    struct tree_node* first_child;
    struct tree_node* last_child;
    struct tree_node* brother_next;
    struct tree_node* brother_prev;
    token_type_t node_type;
    token_type_t implicit_conversion;
} tree_node_t;


tree_node_t* make_tree();
tree_node_t* make_node(void* value);
tree_node_t* insert_child(tree_node_t* father, tree_node_t* children);
tree_node_t* make_ast_node(valor_lexico_t* valor_lexico);
void print_BFS(tree_node_t* head);
void print_DFS(tree_node_t* head);
void clean_tree_DFS(tree_node_t* head);

void libera(tree_node_t *head);
void descompila(tree_node_t *head);
void print_fancy (tree_node_t* head);




#endif
