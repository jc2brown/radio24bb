
#include <stdint.h>
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







void handle_dac_att_cmd(void *arg, struct command *cmd) {
	struct dac_channel *channel = (struct dac_channel *)arg;
	int att_sel = atoi(cmd->tokens[cmd->index++]);
	if (att_sel >= 0 && att_sel <= 3) {
		channel->regs->att = att_sel;
	}
}




void handle_dac_stat_cmd(void *arg, struct command *cmd) {
	struct dac_channel *channel = (struct dac_channel *)arg;

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







void init_dac_channel_context(char *name, void* arg, struct cmd_context *parent_ctx) {

	struct cmd_context *dac_channel_ctx = make_cmd_context(name, arg);
	add_subcontext(parent_ctx, dac_channel_ctx);

	add_command(dac_channel_ctx, "att", handle_dac_att_cmd);
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

