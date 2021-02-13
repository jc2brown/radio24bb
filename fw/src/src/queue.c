
#include <stdlib.h>
#include "queue.h"


int queue_resize(struct queue *q, int new_capacity) {
	if (new_capacity > q->max_capacity) {
		return 1;
	}
	void **data = (void **)realloc(q->data, new_capacity * sizeof(void *));
	if (data == NULL) {
		return 1;
	}
	q->data = data;
	q->capacity = new_capacity;
	return 0;
}


struct queue *make_queue(int initial_capacity, int max_capacity) {
	struct queue *q = (struct queue *)malloc(sizeof(struct queue));
	if (q == NULL) {
		return NULL;
	}
	q->head = 0;
	q->tail = 0;
	q->size = 0;
	q->capacity = initial_capacity;
	q->max_capacity = max_capacity;
	q->data = (void **)malloc(q->capacity * sizeof(void *));
	if (q->data == NULL) {
		return NULL;
	}
	return q;
}



int queue_put(struct queue *q, void *e) {
	if (q->size == q->capacity) {
		if (queue_resize(q, q->capacity*2)) {
			return 1;
		}
	}
	q->data[q->head] = e;
	q->head = (q->head + 1) % q->capacity;
	q->size += 1;
	return 0;
}


int queue_get(struct queue *q, void **e) {
	if (q->size == 0) {
		return 1;
	}	
	*e = q->data[q->tail];
	q->tail = (q->tail + 1) % q->capacity;
	q->size -= 1;
	return 0;
}
