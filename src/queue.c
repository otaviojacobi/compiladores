#include "queue.h"

queue_node_t *create_queue_node(void *value) {
  queue_node_t *new_node = (queue_node_t*)malloc(sizeof(queue_node_t));

  if(!new_node)
    kill("Could not allocate memory for queue node");

  new_node->value = value;
  new_node->next = NULL;
  return new_node;
}

queue_t *create_queue() {
  queue_t *new_queue = (queue_t*)malloc(sizeof(queue_t));

  if(!new_queue)
    kill("Could not allocate memory for queue");

  new_queue->front = NULL;
  new_queue->rear = NULL;
  return new_queue;
}

void queue_push(queue_t *q, void* value) {
  queue_node_t *tmp = create_queue_node(value);

  if(q-> rear == NULL) {
    q->front = q->rear = tmp;
    return;
  }

  q->rear->next = tmp;
  q->rear = tmp;
}

queue_node_t *queue_pop(queue_t *q) {
  if(q->front == NULL)
    return NULL;
  
  queue_node_t *tmp = q->front;
  q->front = q->front->next;

  if(q->front == NULL)
    q->rear = NULL;

  return tmp;  
}

int queue_is_empty(queue_t *q) {
  if(q->rear == NULL && q->front == NULL)
    return 1;
  return 0;
}