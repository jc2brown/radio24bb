
#include <stdint.h>
#include <stdlib.h>
#include "sleep.h"
#include <math.h>

#include "dac.h"
#include "command.h"
#include "roe.h"




#undef trace
#define trace(...)
//#define trace xil_printf





const double outa_filter0_coef[21] = {
		            0.0,
		            0.0, 0.0, 0.0, 0.0, 0.0,
		            0.0, 0.0, 1.0, 0.0, 0.0,
		            0.0, 0.0, 0.0, 0.0, 0.0,
		            0.0, 0.0, 0.0, 0.0, 0.0
};
/*
const double outa_filter1_coef[21] = {
	-0.0043883602, 0.00031565442, 0.0017003562,
	-0.013089587, -0.050334464, -0.094678034, -0.10854188, -0.057842500, 0.052184995,
	0.16681251, 0.21572262, 0.16681251, 0.052184995, -0.057842500, -0.10854188,
	-0.094678034, -0.050334464, -0.013089587, 0.0017003562, 0.00031565442, -0.0043883602
};

//10.7MHz BPF
const double outa_filter2_coef[21] = {
	-0.013109596, 0.0017077012, 0.020202769,
	0.028292382, 0.0037295214, -0.042571224, -0.061360345, -0.0032092702, 0.13130295,
	0.27526412, 0.33749876, 0.27526412, 0.13130295, -0.0032092702, -0.061360345,
	-0.042571224, 0.0037295214, 0.028292382, 0.020202769, 0.0017077012, -0.013109596
};


const double outa_filter3_coef[21] = {
	-0.0028668121, -0.0059479118, -0.0024964532,
	0.014065051, 0.015272200, -0.050134869, -0.16432914, -0.18986124, -0.0040242847,
	0.30052693, 0.45256446, 0.30052693, -0.0040242847, -0.18986124, -0.16432914,
	-0.050134869, 0.015272200, 0.014065051, -0.0024964532, -0.0059479118, -0.0028668121
};
*/






struct dac_channel *make_dac_channel() {
	struct dac_channel *channel = (struct dac_channel *)malloc(sizeof(struct dac_channel));
	return channel;
}



int init_dac_channel_regs(struct dac_channel_regs *regs) {

	regs->gain = 256;
	regs->offset = 0;

	regs->mux = 0;
	regs->raw = 0;

	for (int i = 0; i < 21; ++i) {
		regs->filter_coef = (uint32_t)(1.0*outa_filter0_coef[i] * (double)(1<<19));
	}

	regs->stat_cfg = 0;
	regs->stat_limit = 0;

	regs->att = 0b00;
	regs->amp_en = 1;
	regs->led = 0b000;

	regs->mux = 4;

	return XST_SUCCESS;
}


int init_dac_channel(struct dac_channel *channel, uint32_t regs_addr) {
	trace("init_dac_channel\n");
	channel->regs = (struct dac_channel_regs *)regs_addr;
	_return_if_error_(init_dac_channel_regs(channel->regs));
	return XST_SUCCESS;
}







void handle_dac_opt_cmd(void *arg, struct command *cmd) {
	struct dac_channel *channel = (struct dac_channel *)arg;
	dac_stat(channel);
	int min = (int8_t)channel->regs->stat_min;
	int max = (int8_t)channel->regs->stat_max;
	xil_printf("min:%d  max:%d\n", min, max);
	int ampl = max - min;
	int avg = (min + max) / 2;
	xil_printf("ampl:%d  avg:%d\n", ampl, avg);
	int gain = (256UL * 128UL) / ampl;
	int offset = -avg;
	xil_printf("gain:%d  offset:%d\n", gain, offset);
	channel->regs->gain = gain;
	channel->regs->offset = offset;
}

void handle_dac_gain_cmd(void *arg, struct command *cmd) {
	struct dac_channel *channel = (struct dac_channel *)arg;
	int gain = atoi(cmd->tokens[cmd->index++]);
	if (gain >= 0 && gain <= 65535) {
		channel->regs->gain = gain;
	}
}


void handle_dac_offset_cmd(void *arg, struct command *cmd) {
	struct dac_channel *channel = (struct dac_channel *)arg;
	int offset = atoi(cmd->tokens[cmd->index++]);
	if (offset >= -128 && offset <= 127) {
		channel->regs->offset = offset;
	}
}




void handle_dac_led_cmd(void *arg, struct command *cmd) {
	struct dac_channel *channel = (struct dac_channel *)arg;
	int led = atoi(cmd->tokens[cmd->index++]);
	if (led >= 0 && led <= 7) {
		channel->regs->led = led;
	}
}

  


void handle_dac_src_cmd(void *arg, struct command *cmd) {
	struct dac_channel *channel = (struct dac_channel *)arg;
	static char *dac_srcs[] = { "raw", "ina", "inb", "ddsa", "ddsb", "usb", "aud", "pbka" };
	char *src = cmd->tokens[cmd->index++];
	if (!strcmp(src, "help")) {
		for (int i = 0; i < sizeof(dac_srcs)/sizeof(*dac_srcs); ++i) {
			xil_printf("%d:%s  ", i, dac_srcs[i]);
		}
		xil_printf("\n");
		return;
	}
	for (int i = 0; i < sizeof(dac_srcs)/sizeof(*dac_srcs); ++i) {
		if (!strcmp(src, dac_srcs[i])) {
			channel->regs->mux = i;
		}
	}
}



void handle_dac_att_cmd(void *arg, struct command *cmd) {
	struct dac_channel *channel = (struct dac_channel *)arg;
	int att_sel = atoi(cmd->tokens[cmd->index++]);
	if (att_sel >= 0 && att_sel <= 3) {
		channel->regs->att = att_sel;
	}
}




void dac_stat(struct dac_channel *channel) {
	channel->regs->stat_cfg = 1;
	channel->regs->stat_cfg = 0;
	channel->regs->stat_limit = 1000000000;
	channel->regs->stat_cfg = 2;
	usleep(100000);
	channel->regs->stat_cfg = 0;
}



void handle_dac_stat_cmd(void *arg, struct command *cmd) {
	struct dac_channel *channel = (struct dac_channel *)arg;
	dac_stat(channel);
	xil_printf("STAT: %d .. %d  (%d)\n", (int8_t)channel->regs->stat_min, (int8_t)channel->regs->stat_max, channel->regs->stat_count);
}





void init_dac_channel_context(char *name, void* arg, struct cmd_context *parent_ctx) {

	struct cmd_context *dac_channel_ctx = make_cmd_context(name, arg);
	add_subcontext(parent_ctx, dac_channel_ctx);

	add_command(dac_channel_ctx, "gain", handle_dac_gain_cmd);
	add_command(dac_channel_ctx, "offset", handle_dac_offset_cmd);
	add_command(dac_channel_ctx, "opt", handle_dac_opt_cmd);
	add_command(dac_channel_ctx, "src", handle_dac_src_cmd);
	add_command(dac_channel_ctx, "att", handle_dac_att_cmd);
	add_command(dac_channel_ctx, "led", handle_dac_led_cmd);
	add_command(dac_channel_ctx, "stat", handle_dac_stat_cmd);
}



