

#ifndef LIST_H
#define LIST_H


struct list_node {
	struct list_node *next;
	void *data;
};


int alloc_list_node(struct list_node **n);
void free_list(struct list_node *n);
int init_list_node(struct list_node **n, void *data);
void print_list(struct list_node *n);
int list_append(struct list_node *n, void *data);


#endif
