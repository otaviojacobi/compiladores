#include "tree.h"

tree_node_t *make_tree() {
  return make_node(NULL);
}

tree_node_t *make_node(void *value) {

  tree_node_t *new_node = (tree_node_t *)malloc(sizeof(tree_node_t));

  if (!new_node)
    kill("Couldnt allocate new node");

  new_node->value = value;
  new_node->childAmount = 0;
  new_node->firstChild = NULL;
  new_node->brother = NULL;
}

tree_node_t *insert_child(tree_node_t *father, tree_node_t *children) {

  tree_node_t *current_son = father->firstChild;

  if(!current_son) {
    father->firstChild = children;
  } else {
    for (int i = 0; i < father->childAmount - 1; ++i) {
      current_son = current_son->brother;
    }
    current_son->brother = children;
  }

  father->childAmount++;

  return father;
}

void print_BFS(tree_node_t *head) {
  queue_t *q = create_queue();
  tree_node_t *current_son;


  queue_push(q, head);
  while(!queue_is_empty(q)) {
    queue_node_t* _node = queue_pop(q);
    tree_node_t* node = _node->value;
    printf("%d\n", *((int*)node->value));
    current_son = node->firstChild;
    while(current_son) {
      queue_push(q, current_son);
      current_son = current_son -> brother;
    }
  }
}

void print_DFS(tree_node_t *head) {
  stack_t *q = create_stack();
  tree_node_t *current_son;


  stack_push(q, head);
  while(!stack_is_empty(q)) {
    stack_node_t* _node = stack_pop(q);
    tree_node_t* node = _node->value;
    printf("%d\n", *((int*)node->value));
    current_son = node->firstChild;
    while(current_son) {
      stack_push(q, current_son);
      current_son = current_son -> brother;
    }
  }
}