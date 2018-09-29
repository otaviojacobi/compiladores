#ifndef __QUEUE_H
#define __QUEUE_H

#include <stdlib.h>
#include "utils.h"

typedef struct queue_node {
  void *value;
  struct queue_node *next;
} queue_node_t;

typedef struct queue {
  queue_node_t *front; 
  queue_node_t *rear;
} queue_t;

queue_node_t *create_queue_node(void *value);
queue_t *create_queue();
void queue_push(queue_t *q, void* value);
queue_node_t *queue_pop(queue_t *q);
int queue_is_empty(queue_t *q);

#endif