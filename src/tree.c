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
  new_node->first_child = NULL;
  new_node->last_child = NULL;
  new_node->brother_next = NULL;
  new_node->brother_prev = NULL;

}

tree_node_t *insert_child(tree_node_t *father, tree_node_t *children) {

  tree_node_t *current_son = father->first_child;

  if(!current_son) {
    father->first_child = children;
  } else {
    for (int i = 0; i < father->childAmount - 1; ++i) {
      current_son = current_son->brother_next;
    }
    current_son->brother_next = children;
    current_son->brother_next->brother_prev = current_son;
  }

  father->last_child = children;
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
    current_son = node->first_child;
    while(current_son) {
      queue_push(q, current_son);
      current_son = current_son -> brother_next;
    }
  }
}

void print_DFS(tree_node_t *head) {
  stack_t *s = create_stack();
  tree_node_t *current_son;


  stack_push(s, head);
  while(!stack_is_empty(s)) {
    stack_node_t* _node = stack_pop(s);
    tree_node_t* node = _node->value;
    printf("%d\n", *((int*)node->value));
    current_son = node->last_child;
    while(current_son) {
      stack_push(s, current_son);
      current_son = current_son -> brother_prev;
    }
  }
}