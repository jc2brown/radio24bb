

#include <malloc.h>
#include "string.h"

#include "stringmap.h"




struct stringmap_node *make_stringmap_node(const char *key, void *value, struct stringmap_node *next) {
	struct stringmap_node *map_node = (struct stringmap_node *)malloc(sizeof(struct stringmap_node));
	map_node->next = next;
	map_node->key = key;
	map_node->value = value;
	return map_node;
}


// Update a value for an existing key or add a value for a new key
void stringmap_put(struct stringmap_node *map, const char *key, void *value) {
	if (map == NULL) {
		return;
	}
	while (1) {
		// Replace blank "" placeholder key on first put
		if (!(strcmp(map->key, ""))) {
			map->key = key;
		}
		if (!strcmp(key, map->key)) {
			map->value = value;
			return;
		}
		if (map->next == NULL) {
			map->next = make_stringmap_node(key, value, NULL);
			return;
		}
		map = map->next;
	}
}



void *stringmap_get(struct stringmap_node *map, const char *key) {
	while (1) {
		if (map == NULL) {
			return NULL;
		}
		// Never allow "" as a valid key
		if (strcmp(map->key, "") && !strcmp(key, map->key)) {
			return map->value;
		}
		map = map->next;
	}
}

#if 0

#include "xil_printf.h"

int main() {

	struct stringmap_node *map = make_stringmap_node("", NULL, NULL);

	stringmap_put(map, "one", (void *)1);
	stringmap_put(map, "two", (void *)2);
	stringmap_put(map, "three", (void *)3);

	xil_printf("  > %d\n", (int)stringmap_get(map, "one"));
	xil_printf(" >> %d\n", (int)stringmap_get(map, "two"));
	xil_printf(">>> %d\n", (int)stringmap_get(map, "three"));



}


#endif
