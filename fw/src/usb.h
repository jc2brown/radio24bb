

#ifndef USB_H
#define USB_H



// USB IOExp0 Port 0
#define USB_IOEXP_0_USB_LED_B    	(1<<0)
#define USB_IOEXP_0_USB_LED_G    	(1<<1)
#define USB_IOEXP_0_POWER_LED_B   	(1<<2)
#define USB_IOEXP_0_POWER_LED_G   	(1<<3)
#define USB_IOEXP_0_POWER_LED_COM 	(1<<4)
#define USB_IOEXP_0_POWER_LED_R   	(1<<5)
#define USB_IOEXP_0_USB_LED_R  		(1<<6)
#define USB_IOEXP_0_USB_LED_COM    	(1<<7)

// USB IOExp0 Port 1
// #define CODEC_IOEXP_NOT_CONNECTED (1<<0)
// #define CODEC_IOEXP_NOT_CONNECTED (1<<1)
// #define CODEC_IOEXP_NOT_CONNECTED (1<<2)
// #define CODEC_IOEXP_NOT_CONNECTED (1<<3)
// #define CODEC_IOEXP_NOT_CONNECTED (1<<4)
#define USB_IOEXP_0_SN0      (1<<5)
#define USB_IOEXP_0_SN1      (1<<6)
#define USB_IOEXP_0_SN2      (1<<7)



// USB IOExp1 Port 0
#define USB_IOEXP_1_VBUS_DET_N    	(1<<0)
#define USB_IOEXP_1_USB_GPIO0	   	(1<<1)
#define USB_IOEXP_1_USB_GPIO1   	(1<<2)
#define USB_IOEXP_1_USB_WAKE_N   	(1<<3)
#define USB_IOEXP_1_USB_RESET_N 	(1<<4)
// #define USB_IOEXP_1_NOT_CONNECTED (1<<5)
// #define USB_IOEXP_1_NOT_CONNECTED (1<<6)
// #define USB_IOEXP_1_NOT_CONNECTED (1<<7)



void handle_usb_src_cmd(void *arg, struct command *cmd);
void init_usb_channel_context(char *name, void* arg, struct cmd_context *parent_ctx);
int set_usb_reset_n(struct radio24bb *r24bb, int reset_n);



#endif