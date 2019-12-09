



#include "list.h"
#include <malloc.h>
#include <errno.h>

int alloc_list_node(struct list_node **n) {
	*n = (struct list_node *)malloc(sizeof(struct list_node));
	if (*n == NULL) {
		printf("\nERROR: alloc_list_node failed\n");
		return -ENOMEM;
	}
	return 0;
}


void free_list(struct list_node *n) {
	if (n == NULL) {
		return;
	}
	free_list(n->next);
	free(n);
}


int init_list_node(struct list_node **n, void *data) {
	int error = alloc_list_node(n);
	if (error) {
		return error;
	}
	(*n)->data = data;
	return 0;
}


void print_list(struct list_node *n) {
	if (n == NULL) {
		return;
	}
	printf("%s\n", (char*)n->data);
	print_list(n->next);
}


int list_append(struct list_node *n, void *data) {
	if (n == NULL) {
		printf("list_append: list is NULL\n");
		return 1;
	}

	if (n->next != NULL) {
		return list_append(n->next, data);
	}
	int error = init_list_node(&(n->next), data);
	if (error) {
		printf("ERROR: list_append: init_list_node failed\n");
		return error;
	}
	return 0;
}



