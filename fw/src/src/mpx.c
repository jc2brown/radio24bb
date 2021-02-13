
#include <stdint.h>
#include <stdlib.h>
#include "sleep.h"
#include <math.h>

#include "roe.h"
#include "mpx.h"
#include "command.h"

#include "xil_printf.h"





const double mpx_filter0_coef[21] = {
        0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0
};

const double mpx_filter1_coef[21] = {
        0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0
};

// 50us preemph
const double mpx_filter2_coef[21] = {
	 0.0023105523, 0.0012914991, 0.0027155569,
	-0.00023259330, 0.0031142478, -0.0041380139, 0.0034309880, -0.018794734, 0.0036404781,
	-0.20392541, 0.51917485, -0.20392541, 0.0036404781, -0.018794734, 0.0034309880,
	-0.0041380139, 0.0031142478, -0.00023259330, 0.0027155569, 0.0012914991, 0.0023105523
	
};






struct mpx_channel *make_mpx_channel() {
	struct mpx_channel *channel = (struct mpx_channel *)malloc(sizeof(struct mpx_channel));
	return channel;
}




#define SAMPLE_RATE 9.728e6
uint32_t calc_mpx_step_size(double freq) {
	return ((1ULL<<32) / SAMPLE_RATE) * freq;
}


int init_mpx_channel_regs(struct mpx_channel_regs *regs) {


	regs->stat_cfg = 0;
	regs->stat_limit = 0;

	regs->step = 0;

	for (int i = 0; i < 4096; ++i) {
		regs->rom = (int8_t)(127.0*sin((2.0*3.141*(double)i)/4096.0));
	}

	regs->step = calc_mpx_step_size(19e3);

	regs->pilot_gain = 127;


	for (int i = 0; i < 21; ++i) {
		regs->filter_coef = (uint32_t)(10.0*mpx_filter1_coef[i] * (double)(1<<19));
	}

	return XST_SUCCESS;

}




int init_mpx_channel(struct mpx_channel *channel, uint32_t regs_addr) {
	channel->regs = (struct mpx_channel_regs *)regs_addr;
	_return_if_error_(init_mpx_channel_regs(channel->regs));
	return XST_SUCCESS;
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





void handle_mpx_src_cmd(void *arg, struct command *cmd) {
	struct mpx_channel *channel = (struct mpx_channel *)arg;
	static char *mpx_srcs[] = { "aud", "pbka" };
	char *src = cmd->tokens[cmd->index++];
	if (!strcmp(src, "help")) {
		for (int i = 0; i < sizeof(mpx_srcs)/sizeof(*mpx_srcs); ++i) {
			xil_printf("%d:%s  ", i, mpx_srcs[i]);
		}
		xil_printf("\n");
		return;
	}
	for (int i = 0; i < sizeof(mpx_srcs)/sizeof(*mpx_srcs); ++i) {
		if (!strcmp(src, mpx_srcs[i])) {
			channel->regs->mux = i;
		}
	}
}





void handle_mpx_freq_cmd(void *arg, struct command *cmd) {
	struct mpx_channel *channel = (struct mpx_channel *)arg;
	channel->regs->step = calc_mpx_step_size(atof(cmd->tokens[cmd->index++]));
}




void handle_mpx_pilot_gain_cmd(void *arg, struct command *cmd) {
	struct mpx_channel *channel = (struct mpx_channel *)arg;
	channel->regs->pilot_gain = atoi(cmd->tokens[cmd->index++]);
}




void handle_mpx_filt_cmd(void *arg, struct command *cmd) {
	struct mpx_channel *channel = (struct mpx_channel *)arg;
	int filt = atoi(cmd->tokens[cmd->index++]);
	if (filt == 0) {
		for (int i = 0; i < 21; ++i) {
			channel->regs->filter_coef = (uint32_t)(10.0*mpx_filter0_coef[i] * (double)(1<<19));
		}
	}
	if (filt == 1) {
		for (int i = 0; i < 21; ++i) {
			channel->regs->filter_coef = (uint32_t)(10.0*mpx_filter1_coef[i] * (double)(1<<19));
		}
	}
	if (filt == 2) {
		for (int i = 0; i < 21; ++i) {
			channel->regs->filter_coef = (uint32_t)(10.0*mpx_filter2_coef[i] * (double)(1<<19));
		}
	}
}





void init_mpx_channel_context(char *name, void* arg, struct cmd_context *parent_ctx) {

	struct cmd_context *mpx_channel_ctx = make_cmd_context(name, arg);
	add_subcontext(parent_ctx, mpx_channel_ctx);
	add_command(mpx_channel_ctx, "pilot", handle_mpx_pilot_gain_cmd);
	add_command(mpx_channel_ctx, "stat", handle_mpx_stat_cmd);
	add_command(mpx_channel_ctx, "src", handle_mpx_src_cmd);
	add_command(mpx_channel_ctx, "freq", handle_mpx_freq_cmd);
	add_command(mpx_channel_ctx, "filt", handle_mpx_filt_cmd);


}



