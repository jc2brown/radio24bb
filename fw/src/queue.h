
#include <stdlib.h>

#ifndef QUEUE_H
#define QUEUE_H


struct queue {
	void **data;
	int size;
	int capacity;
	int max_capacity;
	int head;
	int tail;
};


int queue_resize(struct queue *q, int new_capacity);
struct queue *make_queue(int initial_capacity, int max_capacity);
int queue_put(struct queue *q, void *e);
int queue_get(struct queue *q, void **e);


#endif

