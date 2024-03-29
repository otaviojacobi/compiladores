#include "stack.h"

stack_node_t *create_stack_node(void *value) {
  stack_node_t *new_node = (stack_node_t*)malloc(sizeof(stack_node_t));

  if(!new_node)
    kill("Could not allocate memory for stack node");

  new_node->value = value;
  new_node->next = NULL;
  return new_node;
}

stack_t *create_stack() {
  stack_t *new_stack = (stack_t*)malloc(sizeof(stack_t));

  if(!new_stack)
    kill("Could not allocate memory for stack");

  new_stack->front = NULL;
  new_stack->rear = NULL;
  return new_stack;
}

void stack_push(stack_t *s, void* value) {
  stack_node_t *tmp = create_stack_node(value);

  if(s-> rear == NULL) {
    s->front = s->rear = tmp;
    return;
  }

  tmp->next = s->front;
  s->front = tmp;
}

stack_node_t *stack_pop(stack_t *s) {
  if(s->front == NULL)
    return NULL;

  stack_node_t *tmp = s->front;
  s->front = s->front->next;

  if(s->front == NULL)
    s->rear = NULL;

  return tmp;  
}

int stack_is_empty(stack_t *s) {
  if(s->rear == NULL && s->front == NULL)
    return 1;
  return 0;
}

void clean_stack(stack_t *s) {
  stack_node_t *tmp = s->front;
  while(tmp != NULL) {
    tmp = tmp->next;
    free(s->front);
    s->front = tmp;
  }

  free(s);
}