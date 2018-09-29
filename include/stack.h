#ifndef __STACK_H
#define __STACK_H

#include <stdlib.h>

typedef struct stack_node {
  void *value;
  struct stack_node *next;
} stack_node_t;

typedef struct stack {
  stack_node_t *front; 
  stack_node_t *rear;
} stack_t;

stack_node_t *create_stack_node(void *value);
stack_t *create_stack();
void stack_push(stack_t *q, void* value);
stack_node_t *stack_pop(stack_t *q);
int stack_is_empty(stack_t *q);

#endif