
#include <stdint.h>
#include <stdlib.h>
#include "command.h"

#include "adc.h"
#include "xil_printf.h"
#include "sleep.h"





struct adc_channel *make_adc_channel(uint32_t regs_addr) {
	struct adc_channel *channel = (struct adc_channel *)malloc(sizeof(struct adc_channel));
	channel->regs = (struct adc_channel_regs *)regs_addr;
	init_adc_channel_regs(channel->regs);
	return channel;
}



void init_adc_channel(struct adc_channel *channel) {
	init_adc_channel_regs(channel->regs);
}




void init_adc_channel_regs(struct adc_channel_regs *regs) {

	regs->gain = 256;
	regs->offset = 0;

	for (int i = 0; i < 21; ++i) {
		regs->filter_coef = (uint32_t)(ina_filter0_coef[i] * (double)(1<<23));
	}

	regs->stat_cfg = 0;
	regs->stat_limit = 0;


	regs->att = 0b00;
	regs->amp_en = 1;
	regs->led = 0b001;

}


void handle_adc_gain_cmd(void *arg, struct command *cmd) {
	struct adc_channel *channel = (struct adc_channel *)arg;
	int gain = atoi(cmd->tokens[cmd->index++]);
	if (gain >= 0 && gain <= 65535) {
		channel->regs->gain = gain;
	}
}


void handle_adc_offset_cmd(void *arg, struct command *cmd) {
	struct adc_channel *channel = (struct adc_channel *)arg;
	int offset = atoi(cmd->tokens[cmd->index++]);
	if (offset >= -128 && offset <= 127) {
		channel->regs->offset = offset;
	}
}


void handle_adc_opt_cmd(void *arg, struct command *cmd) {
	struct adc_channel *channel = (struct adc_channel *)arg;
	adc_stat(channel);
	int min = channel->regs->stat_min;
	int max = channel->regs->stat_max;
	int ampl = max - min;
	int avg = (min + max) / 2;
	channel->regs->gain = (256UL * 128UL) / ampl;
	channel->regs->offset = -avg;
}




void handle_adc_led_cmd(void *arg, struct command *cmd) {
	struct adc_channel *channel = (struct adc_channel *)arg;
	int led = atoi(cmd->tokens[cmd->index++]);
	if (led >= 0 && led <= 7) {
		channel->regs->led = led;
	}
}


void handle_adc_att_cmd(void *arg, struct command *cmd) {
	struct adc_channel *channel = (struct adc_channel *)arg;
	int att_sel = atoi(cmd->tokens[cmd->index++]);
	if (att_sel >= 0 && att_sel <= 3) {
		channel->regs->att = att_sel;
	}
}



void adc_stat(struct adc_channel *channel) {
	channel->regs->stat_cfg = 1;
	channel->regs->stat_cfg = 0;
	channel->regs->stat_limit = 1000000000;
	channel->regs->stat_cfg = 2;
	usleep(100000);
	channel->regs->stat_cfg = 0;
}



void handle_adc_stat_cmd(void *arg, struct command *cmd) {
	struct adc_channel *channel = (struct adc_channel *)arg;
	adc_stat(channel);
	xil_printf("STAT: %d .. %d  (%d)\n", (int8_t)channel->regs->stat_min, (int8_t)channel->regs->stat_max, channel->regs->stat_count);
}




void init_adc_channel_context(char *name, void* arg, struct cmd_context *parent_ctx) {

	struct cmd_context *adc_channel_ctx = make_cmd_context(name, arg);
	add_subcontext(parent_ctx, adc_channel_ctx);

	add_command(adc_channel_ctx, "gain", handle_adc_gain_cmd);
	add_command(adc_channel_ctx, "offset", handle_adc_offset_cmd);
	add_command(adc_channel_ctx, "opt", handle_adc_opt_cmd);
	add_command(adc_channel_ctx, "att", handle_adc_att_cmd);
	add_command(adc_channel_ctx, "led", handle_adc_led_cmd);
	add_command(adc_channel_ctx, "stat", handle_adc_stat_cmd);
}




