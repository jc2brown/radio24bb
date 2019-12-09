
#include <stdint.h>
#include <stdlib.h>
#include "sleep.h"
#include <math.h>

#include "dac.h"
#include "command.h"






struct dac_channel *make_dac_channel(uint32_t regs_addr) {
	struct dac_channel *channel = (struct dac_channel *)malloc(sizeof(struct dac_channel));
	channel->regs = (struct dac_channel_regs *)regs_addr;
	init_dac_channel_regs(channel->regs);
	return channel;
}



void init_dac_channel(struct dac_channel *channel) {
	init_dac_channel_regs(channel->regs);
}



void init_dac_channel_regs(struct dac_channel_regs *regs) {

	regs->gain = 256;
	regs->offset = 0;

	regs->mux = 0;
	regs->raw = 0;

	for (int i = 0; i < 21; ++i) {
		regs->filter_coef = (uint32_t)(outa_filter0_coef[i] * (double)(1<<23));
	}

	regs->stat_cfg = 0;
	regs->stat_limit = 0;


	regs->dds_step = 0;

	for (int i = 0; i < 4096; ++i) {
		regs->dds_cfg = (int8_t)(127.0*sin((2.0*3.141*(double)i)/4096.0));

	}

	regs->dds_step = ((1ULL<<32) / 99.99888e6) * 19.7e6;




	regs->att = 0b11;
	regs->amp_en = 1;
	regs->led = 0b001;


	regs->dds_fm_mux = 1;
	regs->dds_fm_raw = 0;
	regs->dds_fm_gain = ((1ULL<<32) / 99.99888e6) * 0.95e3; // 100kHz / 0.5V ADC
	regs->dds_fm_offset = 00000000;


	regs->mux = 4;
}






void handle_dac_opt_cmd(void *arg, struct command *cmd) {
	struct dac_channel *channel = (struct dac_channel *)arg;
	dac_stat(channel);
	int min = channel->regs->stat_min;
	int max = channel->regs->stat_max;
	int ampl = max - min;
	int avg = (min + max) / 2;
	channel->regs->gain = (256UL * 128UL) / ampl;
	channel->regs->offset = -avg;
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
	static char *dac_srcs[] = { "raw", "ina", "inb", "usb", "dds", "prbs" };
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






/*
 *

localparam REG_GAIN = 12'h000;
localparam REG_OFFSET = 12'h04;
localparam REG_FILTER_COEF = 12'h08;
localparam REG_STAT_CFG   = 12'h0C;
localparam REG_STAT_MIN   = 12'h10;
localparam REG_STAT_MAX   = 12'h14;
localparam REG_STAT_LIMIT = 12'h18;
localparam REG_STAT_COUNT = 12'h1C;

*/

