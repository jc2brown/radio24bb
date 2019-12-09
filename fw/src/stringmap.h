#ifndef STRINGMAP_H
#define STRINGMAP_H


#include <malloc.h>


struct stringmap_node {
	struct stringmap_node *next;
	const char *key;
	void *value;
};


struct stringmap_node *make_stringmap_node(const char *key, void *value, struct stringmap_node *next);
void stringmap_put(struct stringmap_node *map, const char *key, void *value) ;
void *stringmap_get(struct stringmap_node *map, const char *key);


#endif
