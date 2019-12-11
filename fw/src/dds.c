
#include <stdint.h>
#include <stdlib.h>
#include "sleep.h"
#include <math.h>

#include "dds.h"
#include "command.h"

#include "xil_printf.h"


struct dds_channel *make_dds_channel(uint32_t regs_addr) {
	struct dds_channel *channel = (struct dds_channel *)malloc(sizeof(struct dds_channel));
	channel->regs = (struct dds_channel_regs *)regs_addr;
	init_dds_channel_regs(channel->regs);
	return channel;
}



void init_dds_channel(struct dds_channel *channel) {
	init_dds_channel_regs(channel->regs);
}


#define SAMPLE_RATE 99.99888e6
uint32_t calc_step_size(double freq) {
	return ((1ULL<<32) / SAMPLE_RATE) * freq;
}

void init_dds_channel_regs(struct dds_channel_regs *regs) {

	regs->mux = 1;
	regs->raw = 0;


	regs->stat_cfg = 0;
	regs->stat_limit = 0;

	regs->step = 0;

	for (int i = 0; i < 4096; ++i) {
		regs->rom = (int8_t)(127.0*sin((2.0*3.141*(double)i)/4096.0));
	}

	// regs->step = ((1ULL<<32) / 99.99888e6) * 19.7e6;
	regs->step = calc_step_size(19.7e6);

	regs->am_mux = 0;
	regs->am_raw = 127;
	regs->am_gain = 256;
	regs->am_offset = 0;

	regs->fm_mux = 1;
	regs->fm_raw = 0;
	// regs->fm_gain = 956301; // 5.7MHz FS dev. @ 5MHz fc & 100MSps
	regs->fm_gain = 33554; // 200kHz FS dev. @ 10.7MHz fc & 100MSps
	regs->fm_offset = 0;
	

	regs->pm_mux = 0;
	regs->pm_raw = 0;
	regs->pm_gain = 4096;
	regs->pm_offset = 0;

	regs->prbs_gain = 0;
	regs->prbs_offset = 0;

}



void handle_dds_src_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	static char *dds_srcs[] = { "raw", "dds", "ina", "inb" };
	char *src = cmd->tokens[cmd->index++];
	if (!strcmp(src, "help")) {
		for (int i = 0; i < sizeof(dds_srcs)/sizeof(*dds_srcs); ++i) {
			xil_printf("%d:%s  ", i, dds_srcs[i]);
		}
		xil_printf("\n");
		return;
	}
	for (int i = 0; i < sizeof(dds_srcs)/sizeof(*dds_srcs); ++i) {
		if (!strcmp(src, dds_srcs[i])) {
			channel->regs->mux = i;
		}
	}
}



void handle_dds_raw_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->raw = atoi(cmd->tokens[cmd->index++]);
}



void dds_stat(struct dds_channel *channel) {
	channel->regs->stat_cfg = 1;
	channel->regs->stat_cfg = 0;
	channel->regs->stat_limit = 1000000000;
	channel->regs->stat_cfg = 2;
	usleep(100000);
	channel->regs->stat_cfg = 0;
}



void handle_dds_stat_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	dds_stat(channel);
	xil_printf("STAT: %d .. %d  (%d)\n", (int8_t)channel->regs->stat_min, (int8_t)channel->regs->stat_max, channel->regs->stat_count);
}





void handle_dds_freq_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->step = calc_step_size(atof(cmd->tokens[cmd->index++]));
}





void handle_dds_am_src_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	static char *dds_am_srcs[] = { "raw", "ina", "inb", "ddsa", "ddsb" };
	char *src = cmd->tokens[cmd->index++];
	if (!strcmp(src, "help")) {
		for (int i = 0; i < sizeof(dds_am_srcs)/sizeof(*dds_am_srcs); ++i) {
			xil_printf("%d:%s  ", i, dds_am_srcs[i]);
		}
		xil_printf("\n");
		return;
	}
	for (int i = 0; i < sizeof(dds_am_srcs)/sizeof(*dds_am_srcs); ++i) {
		if (!strcmp(src, dds_am_srcs[i])) {
			xil_printf("am_mux<=%d\n", i);
			channel->regs->am_mux = i;
		}
	}
}

void handle_dds_am_raw_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->am_raw = atoi(cmd->tokens[cmd->index++]);
}


void handle_dds_am_gain_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->am_gain = atoi(cmd->tokens[cmd->index++]);
}


void handle_dds_am_offset_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->am_offset = atoi(cmd->tokens[cmd->index++]);
}









void handle_dds_fm_src_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	static char *dds_fm_srcs[] = { "raw", "ina", "inb", "ddsa", "ddsb" };
	char *src = cmd->tokens[cmd->index++];
	if (!strcmp(src, "help")) {
		for (int i = 0; i < sizeof(dds_fm_srcs)/sizeof(*dds_fm_srcs); ++i) {
			xil_printf("%d:%s  ", i, dds_fm_srcs[i]);
		}
		xil_printf("\n");
		return;
	}
	for (int i = 0; i < sizeof(dds_fm_srcs)/sizeof(*dds_fm_srcs); ++i) {
		if (!strcmp(src, dds_fm_srcs[i])) {
			xil_printf("fm_mux<=%d\n", i);
			channel->regs->fm_mux = i;
		}
	}
}

void handle_dds_fm_raw_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->fm_raw = atoi(cmd->tokens[cmd->index++]);
}


void handle_dds_fm_gain_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->fm_gain = atoi(cmd->tokens[cmd->index++]);
}


void handle_dds_fm_offset_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->fm_offset = atoi(cmd->tokens[cmd->index++]);
}










void handle_dds_pm_src_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	static char *dds_pm_srcs[] = { "raw", "ina", "inb", "ddsa", "ddsb" };
	char *src = cmd->tokens[cmd->index++];
	if (!strcmp(src, "help")) {
		for (int i = 0; i < sizeof(dds_pm_srcs)/sizeof(*dds_pm_srcs); ++i) {
			xil_printf("%d:%s  ", i, dds_pm_srcs[i]);
		}
		xil_printf("\n");
		return;
	}
	for (int i = 0; i < sizeof(dds_pm_srcs)/sizeof(*dds_pm_srcs); ++i) {
		if (!strcmp(src, dds_pm_srcs[i])) {
			xil_printf("pm_mux<=%d\n", i);
			channel->regs->pm_mux = i;
		}
	}
}

void handle_dds_pm_raw_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->pm_raw = atoi(cmd->tokens[cmd->index++]);
}


void handle_dds_pm_gain_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->pm_gain = atoi(cmd->tokens[cmd->index++]);
}


void handle_dds_pm_offset_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->pm_offset = atoi(cmd->tokens[cmd->index++]);
}










void handle_prbs_gain_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->prbs_gain = atoi(cmd->tokens[cmd->index++]);
}


void handle_prbs_offset_cmd(void *arg, struct command *cmd) {
	struct dds_channel *channel = (struct dds_channel *)arg;
	channel->regs->prbs_offset = atoi(cmd->tokens[cmd->index++]);
}





void init_dds_channel_context(char *name, void* arg, struct cmd_context *parent_ctx) {

	struct cmd_context *dds_channel_ctx = make_cmd_context(name, arg);
	add_subcontext(parent_ctx, dds_channel_ctx);
	add_command(dds_channel_ctx, "src", handle_dds_src_cmd);
	add_command(dds_channel_ctx, "stat", handle_dds_stat_cmd);
	add_command(dds_channel_ctx, "freq", handle_dds_freq_cmd);


	struct cmd_context *am_ctx = make_cmd_context("am", arg);
	add_subcontext(dds_channel_ctx, am_ctx);
	add_command(am_ctx, "src", handle_dds_am_src_cmd);
	add_command(am_ctx, "raw", handle_dds_am_raw_cmd);
	add_command(am_ctx, "gain", handle_dds_am_gain_cmd);
	add_command(am_ctx, "offset", handle_dds_am_offset_cmd);


	struct cmd_context *fm_ctx = make_cmd_context("fm", arg);
	add_subcontext(dds_channel_ctx, fm_ctx);
	add_command(fm_ctx, "src", handle_dds_fm_src_cmd);
	add_command(fm_ctx, "raw", handle_dds_fm_raw_cmd);
	add_command(fm_ctx, "gain", handle_dds_fm_gain_cmd);
	add_command(fm_ctx, "offset", handle_dds_fm_offset_cmd);


	struct cmd_context *pm_ctx = make_cmd_context("pm", arg);
	add_subcontext(dds_channel_ctx, pm_ctx);
	add_command(pm_ctx, "src", handle_dds_pm_src_cmd);
	add_command(pm_ctx, "raw", handle_dds_pm_raw_cmd);
	add_command(pm_ctx, "gain", handle_dds_pm_gain_cmd);
	add_command(pm_ctx, "offset", handle_dds_pm_offset_cmd);


	struct cmd_context *prbs_ctx = make_cmd_context("prbs", arg);
	add_subcontext(dds_channel_ctx, prbs_ctx);
	add_command(prbs_ctx, "gain", handle_prbs_gain_cmd);
	add_command(prbs_ctx, "offset", handle_prbs_offset_cmd);



}



