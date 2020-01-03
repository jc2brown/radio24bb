#include <stdio.h>
#include "stringmap.h"
#include <stdbool.h>
#include "command.h"
#include "roe.h"
#include "xil_printf.h"

void stub_handler() {
	xil_printf("\nERROR: STUB HANDLER CALLED\n");
}




struct cmd_shell *make_cmd_shell(char *root_ctx_name, void *root_ctx_arg) {
	
	struct cmd_shell *shell = (struct cmd_shell *)malloc(sizeof(struct cmd_shell));
	if (shell == NULL) return NULL;

	shell->root_ctx = make_cmd_context(root_ctx_name, root_ctx_arg);
	if (shell->root_ctx == NULL) return NULL;

	shell->cmd = (struct command *)malloc(sizeof(struct command));
	if (shell->cmd == NULL) return NULL;

	shell->cur_ctx = shell->root_ctx;
	shell->inited = 1;

	return shell;
}






struct cmd_context *make_cmd_context(char *name, void *arg) {

	struct cmd_context *ctx = (struct cmd_context *)malloc(sizeof(struct cmd_context));
	if (ctx == NULL) return NULL;

	ctx->subcontexts = make_stringmap_node("", NULL, NULL);
	if (ctx->subcontexts == NULL) return NULL;

	ctx->commands = make_stringmap_node("", stub_handler, NULL);
	if (ctx->commands == NULL) return NULL;

	ctx->parent = NULL;
	ctx->name = name;
	ctx->arg = arg;

	return ctx;
}






void add_subcontext(struct cmd_context *ctx, struct cmd_context *subctx) {
	if (ctx == NULL) return;
//	assert(ctx != NULL);
	subctx->parent = ctx;
	stringmap_put(ctx->subcontexts, subctx->name, subctx);
}


void add_command(struct cmd_context *ctx, char *name, void (*handler)(void *, struct command *)) {
	if (ctx == NULL) return;
//	assert(ctx != NULL);
	stringmap_put(ctx->commands, name, handler);
}





static bool print_cmd_ok = false;


void print_cmd_responses(bool print_responses) {
	//print_cmd_ok = print_responses;
}


// TODO: add context
void _run_script(struct cmd_shell *shell, char **script, int num_lines) {
	print_cmd_ok = false;
	for (int i = 0; i < num_lines; ++i) {
		issue_command(shell, script[i], NULL);
	}
	//print_cmd_ok = true;
}





void init_command(struct command *cmd) {
	cmd->index = 0;
	//cmd->line[0] = '\0';   // Assume the user will write this before tokenize() 
	cmd->num_tokens = 0;
	for (int i = 0; i < 16; ++i) {
		cmd->tokens[i] = (char*)"";
	}
}




void tokenize_command(char *cmd_str, struct command *cmd) {
	init_command(cmd);
	for (char *c = (char*)cmd_str; *c != '\0'; ++c) {
		if (isgraph(*c)) {
			if (c == cmd_str || !isgraph(*(c-1))) { // Relying on short-circuit to prevent accessing line-1
				cmd->tokens[cmd->num_tokens++] = c;
			}
		} else {
			*c = '\0';
		}
	}
}



void get_command(struct command *cmd) {
	fgets(cmd->line, 1024, stdin);
	tokenize_command(cmd->line, cmd);
}





struct cmd_context *dispatch_command(struct cmd_context *ctx, struct command *cmd) {

	struct cmd_context *orig_ctx = ctx;

	if (cmd->num_tokens == 0) {
		xil_printf("ERROR: blank command\n");
		return orig_ctx;
	} 




	while (1) {

		char *token = cmd->tokens[cmd->index++];
		bool valid_token = false;
		//xil_printf("token=%s  idx=%d  #=%d\n", token, cmd->index, cmd->num_tokens);

		struct cmd_context *subctx = (struct cmd_context *)stringmap_get(ctx->subcontexts, token);
		if (subctx != NULL) {
			// xil_printf("\nSUBCTX %s\n", token);
			ctx = subctx;
			valid_token = true;
//			xil_printf("Entering context: %s\n", token);
			//continue;
		}

		else {

			handler_fcn handler = (void (*)(void*, struct command *))stringmap_get(ctx->commands, token);
			if (handler != NULL) {
				// xil_printf("\nCMD %s\n", token);
				handler(ctx->arg, cmd);
				if (print_cmd_ok) {
					xil_printf(" OK\n");
				}
	//			xil_printf("Calling command: %s\n", token);
				valid_token = true;
				ctx = orig_ctx;
				//return orig_ctx;
			}
		}


		if (valid_token) {
			// xil_printf("%s ", token);
		}


		//xil_printf("Unrecognized command: %s\n", token);


		if (!valid_token) {
			if (print_cmd_ok) {
				xil_printf(" Unrecognized command: %s\n", token);
			}
			return orig_ctx;
		}

		if (cmd->index == cmd->num_tokens) {
			// xil_printf("\nDONE\n");
			return ctx;
		}

	}

}





void print_ctx_path(struct cmd_context *ctx) {
	if (ctx == NULL) {
		return;
	}
	print_ctx_path(ctx->parent);
	xil_printf("%s ", ctx->name);
}


// static struct cmd_context *root_ctx;
// static struct cmd_context *ctx;
// static struct command cmd;




void init_root_context(struct cmd_shell *shell) {
	static int inited = 0;
	if (shell->inited) {
		return;
	}
	shell->root_ctx = make_cmd_context("bbX", NULL);
	shell->inited = 1;
	set_root_context(shell);
}



void set_root_context(struct cmd_shell *shell) {
	init_root_context(shell);
	shell->cur_ctx = shell->root_ctx;
}


struct cmd_context *get_root_context(struct cmd_shell *shell) {
	init_root_context(shell);
	return shell->root_ctx;
}




struct cmd_context * issue_command(struct cmd_shell *shell, char *cmd_str, struct cmd_context *ctx) {
	struct command cmd;
	init_command(&cmd);
	tokenize_command(cmd_str, &cmd);
	if (ctx == NULL) {
		ctx = get_root_context(shell);
	}
	return dispatch_command(ctx, &cmd);
}


void cmd_prompt(struct cmd_shell *shell) {
	xil_printf("$ ");
	print_ctx_path(shell->cur_ctx);
	xil_printf("> ");
}


void handle_command(struct cmd_shell *shell, char *cmd_str) {


	//		xil_printf("$ %s> ", ctx->name);

	strcpy(shell->cmd->line, cmd_str);
	tokenize_command(shell->cmd->line, shell->cmd);

	if (!strcmp("exit", shell->cmd->tokens[0])) {
		if (shell->cur_ctx != shell->root_ctx) {
			shell->cur_ctx = shell->cur_ctx->parent;
		}
	}
	else if (!strcmp("root", shell->cmd->tokens[0])) {
		shell->cur_ctx = shell->root_ctx;
	}
	else if (!strcmp("help", shell->cmd->tokens[0]) || !strcmp("ls", shell->cmd->tokens[0])) {

		struct stringmap_node *map;

		map = shell->cur_ctx->subcontexts;
		if (strcmp(map->key, "")) {
			xil_printf("Sub-contexts of '%s' context:\n", shell->cur_ctx->name);
			for (; map != NULL; map = map->next) {
				xil_printf("   %s\n", map->key);
			}
		}

		map = shell->cur_ctx->commands;
		if (strcmp(map->key, "")) {
			xil_printf("Commands of '%s' context:\n", shell->cur_ctx->name);
			for (; map != NULL; map = map->next) {
				xil_printf("   %s\n", map->key);
			}
		}

	}
	else {
		shell->cur_ctx = dispatch_command(shell->cur_ctx, shell->cmd);
	}
	cmd_prompt(shell);

}







#if 0



int main() {

	xil_printf("Hello!\n");


	root_ctx = make_cmd_context("/", (void *)100);
	ctx = root_ctx;


	init_adc_channel_context("ina", 200, root_ctx);
	init_adc_channel_context("inb", 300, root_ctx);





	while (1) {

		handle_command();

	}

}




struct cmd_node {
	struct list_node *children;
	void *handler(struct cmd_node *);
};


//struct cmd_node *n alloc_cmd_node(struct cmd_node *n) {
//	n = (struct cmd_node *)malloc(sizeof(struct cmd_node));
//	if (n == NULL) {
//		printf("\nERROR: alloc_node failed\n");
//		return -ENOMEM;
//	}
//	return 0;
//}




void stub_handler() {
	printf("\nERROR: STUB HANDLER CALLED\n");
}



struct cmd_node *make_cmd_node(struct list_node *context_cmd_list, char *cmd) {
	struct cmd_node *n = (struct cmd_node *)malloc(sizeof(struct cmd_node));
	if (n == NULL) {
		xil_printf("ERROR: make_cmd_node: malloc failed\n");
		return NULL;
	}
	n->context_cmd_list = context_cmd_list;
	n->handler = cmd;
	return n;
}


struct cmd_node *make_cmd(char *cmd) {
	return make_cmd_node(NULL, cmd);
}




struct cmd_node *cmd_root = make_cmd_node(NULL);


struct cmd_node *adc1_cmd_node =
		add_child_cmd(cmd_root, make_cmd_node(cmd_root, );

init_cmd_node(&)




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



struct command {
	char line[1024];
	char *tokens[16];
	int num_tokens;
	int index;
};



struct CommandMap {
	char *cmd;
	void handler(struct command &);
};



void get_command(struct command &cmd);



#endif
