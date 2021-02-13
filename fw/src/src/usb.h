

#ifndef USB_H
#define USB_H





void handle_usb_src_cmd(void *arg, struct command *cmd);
void init_usb_channel_context(char *name, void* arg, struct cmd_context *parent_ctx);




#endif