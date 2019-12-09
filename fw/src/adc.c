
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


void handle_adc_att_cmd(void *arg, struct command *cmd) {
	struct adc_channel *channel = (struct adc_channel *)arg;
	int att_sel = atoi(cmd->tokens[cmd->index++]);
	if (att_sel >= 0 && att_sel <= 3) {
		channel->regs->att = att_sel;
	}
}




void handle_adc_stat_cmd(void *arg, struct command *cmd) {
	struct adc_channel *channel = (struct adc_channel *)arg;

	channel->regs->stat_cfg = 1;
	channel->regs->stat_cfg = 0;
	channel->regs->stat_limit = 1000000000;
	channel->regs->stat_cfg = 2;
	usleep(100000);
	channel->regs->stat_cfg = 0;

	xil_printf("MIN: %d\n", (int8_t)channel->regs->stat_min);
	xil_printf("MAX: %d\n", (int8_t)channel->regs->stat_max);
	xil_printf("COUNT: %d\n", channel->regs->stat_count);

}




void init_adc_channel_context(char *name, void* arg, struct cmd_context *parent_ctx) {

	struct cmd_context *adc_channel_ctx = make_cmd_context(name, arg);
	add_subcontext(parent_ctx, adc_channel_ctx);

	struct cmd_context *led_ctx = make_cmd_context("led", arg);
	add_subcontext(adc_channel_ctx, led_ctx);

	add_command(adc_channel_ctx, "att", handle_adc_att_cmd);
	add_command(adc_channel_ctx, "stat", handle_adc_stat_cmd);
}




