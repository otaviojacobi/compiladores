#ifndef __TREE_H
#define __TREE_H

#include <stdlib.h>
#include <stdio.h>
#include "utils.h"
#include "queue.h"
#include "stack.h"

typedef struct tree_node {
    void *value;
    int childAmount;
    struct tree_node* firstChild;
    struct tree_node* brother;
} tree_node_t;


tree_node_t* make_tree();
tree_node_t* make_node(void* value);
tree_node_t *insert_child(tree_node_t *father, tree_node_t *children);
void print_BFS(tree_node_t *head);
void print_DFS(tree_node_t *head);



#endif
