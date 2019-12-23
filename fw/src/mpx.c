
#include <stdint.h>
#include <stdlib.h>
#include "sleep.h"
#include <math.h>

#include "mpx.h"
#include "command.h"

#include "xil_printf.h"


struct mpx_channel *make_mpx_channel(uint32_t regs_addr) {
	struct mpx_channel *channel = (struct mpx_channel *)malloc(sizeof(struct mpx_channel));
	channel->regs = (struct mpx_channel_regs *)regs_addr;
	init_mpx_channel_regs(channel->regs);
	return channel;
}



void init_mpx_channel(struct mpx_channel *channel) {
	init_mpx_channel_regs(channel->regs);
}


#define SAMPLE_RATE 99.99888e6
uint32_t calc_mpx_step_size(double freq) {
	return ((1ULL<<32) / SAMPLE_RATE) * freq;
}

void init_mpx_channel_regs(struct mpx_channel_regs *regs) {


	regs->stat_cfg = 0;
	regs->stat_limit = 0;

	regs->step = 0;

	for (int i = 0; i < 4096; ++i) {
		regs->rom = (int8_t)(127.0*sin((2.0*3.141*(double)i)/4096.0));
	}

	// regs->step = ((1ULL<<32) / 99.99888e6) * 19.7e6;
	regs->step = calc_mpx_step_size(19e3);

	regs->pilot_gain = 256;

}






void mpx_stat(struct mpx_channel *channel) {
	channel->regs->stat_cfg = 1;
	channel->regs->stat_cfg = 0;
	channel->regs->stat_limit = 1000000000;
	channel->regs->stat_cfg = 2;
	usleep(100000);
	channel->regs->stat_cfg = 0;
}



void handle_mpx_stat_cmd(void *arg, struct command *cmd) {
	struct mpx_channel *channel = (struct mpx_channel *)arg;
	mpx_stat(channel);
	xil_printf("STAT: %d .. %d  (%d)\n", (int8_t)channel->regs->stat_min, (int8_t)channel->regs->stat_max, channel->regs->stat_count);
}



void handle_mpx_freq_cmd(void *arg, struct command *cmd) {
	struct mpx_channel *channel = (struct mpx_channel *)arg;
	channel->regs->step = calc_step_size(atof(cmd->tokens[cmd->index++]));
}




void handle_mpx_pilot_gain_cmd(void *arg, struct command *cmd) {
	struct mpx_channel *channel = (struct mpx_channel *)arg;
	channel->regs->pilot_gain = atoi(cmd->tokens[cmd->index++]);
}





void init_mpx_channel_context(char *name, void* arg, struct cmd_context *parent_ctx) {

	struct cmd_context *mpx_channel_ctx = make_cmd_context(name, arg);
	add_subcontext(parent_ctx, mpx_channel_ctx);
	add_command(mpx_channel_ctx, "pilot", handle_mpx_pilot_gain_cmd);
	add_command(mpx_channel_ctx, "stat", handle_mpx_stat_cmd);
	add_command(mpx_channel_ctx, "freq", handle_mpx_freq_cmd);


}



