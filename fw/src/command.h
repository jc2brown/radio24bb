

#ifndef COMMAND_H
#define COMMAND_H




#include "stringmap.h"
#include <stdbool.h>



struct cmd_context {
	struct cmd_context *parent;
	char *name;
	void *arg;
	struct stringmap_node *subcontexts;
	struct stringmap_node *commands;
};




struct command {
	char line[1024];
	char *tokens[16];
	int num_tokens;
	int index;
};



typedef void (*handler_fcn)(void *, struct command *);


struct cmd_context *make_cmd_context(const char *name, void *arg);
void add_subcontext(struct cmd_context *ctx, struct cmd_context *subctx);
void add_command(struct cmd_context *ctx, const char *name, handler_fcn);

void print_cmd_responses(bool print_responses);


void init_root_context();
void set_root_context();
struct cmd_context *get_root_context();



struct cmd_context * issue_command(const char *cmd_str, struct cmd_context *ctx);
void handle_command();



#define run_script(script)  _run_script((script), sizeof((script))/sizeof(*(script)))


void _run_script(char **script, int num_lines);


//void stub_handler();



#if 0




struct node {
	struct node *parent;
	struct list_node **children;
	void *handler(struct node *);
};


int alloc_node(struct node *n) {
	n = (struct node *)malloc(sizeof(struct node));
	if (n == NULL) {
		printf("\nERROR: alloc_node failed\n");
		return -ENOMEM;
	}
	return 0;
}





int init_node(struct node *n, struct node *parent) {
	int error = alloc_node(n);
	if (error) {
		return error;
	}
	n->parent = parent;
	n->handler = stub_handler;
	return 0;
}




int add_child(struct node *n, struct )





	// parent
	// list of children
	// handler

	/*

	If more tokens to process:
		recursively try each child command
		If match

	If no more tokens to process:
		If handler != NULL:
			handler()
		Else:
			error/no matching command

	Else:
		If




	*/

	CmdMap map;
	void handler(struct CmdNode *);
}



class CmdMap(std::unordered_map<std::string, CmdNode>) {

public:


private:



};




/*

root
  |--reset -> reset_handler
  |--ina
      |--on -> ina.on_off_handler
      |--off -> ina.on_off_handler
      |--att -> ina.att_handler
  |--inb
      |--on -> inb.on_off_handler
      |--off -> inb.on_off_handler
      |--att -> inb.att_handler
  |--outa
      |--on -> outa.on_off_handler
      |--off -> outa.on_off_handler
      |--att -> outa.att_handler



*/





struct CmdNode {
	struct CmdNode parent;
	void handler(struct CmdNode *);
	struct CmdNode children[];
	struct CmdNode num_children;
};


void add_child_cmd(struct CmdNode *node, char *str, void handler(struct CmdNode *)) {

	realloc()

	node.append_child(str, handler);
}

struct CmdNode root;

struct CmdNode *ina_root = root.add_child_cmd("ina", ina.root_handler);

struct CmdNode *ina_on = ina_root.add_child_cmd("on", ina.on_off_handler);
struct CmdNode *ina_off = ina_root.add_child_cmd("off", ina.on_off_handler);
struct CmdNode *ina_att = ina_root.add_child_cmd("att", ina.att_handler);


root.add_child_cmd("inb", inb.root_handler);





struct CommandMap {
	char *cmd;
	void handler(struct command &);
};

#endif

#endif
