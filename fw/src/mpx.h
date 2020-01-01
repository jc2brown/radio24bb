
#ifndef MPX_H
#define MPX_H

#include "command.h"

struct mpx_channel {
	struct mpx_channel_regs *regs;
};





struct mpx_channel *make_mpx_channel();

int init_mpx_channel(struct mpx_channel *channel, uint32_t regs_addr);

void init_mpx_channel_context(char *name, void *arg, struct cmd_context *parent_ctx) ;





struct mpx_channel_regs {

	uint32_t pilot_gain;

	uint32_t rom;

	uint32_t step;

	uint32_t stat_cfg;
	uint32_t stat_min;
	uint32_t stat_max;
	uint32_t stat_limit;
	uint32_t stat_count;

	uint32_t filter_coef;
};



extern const double mpx_filter0_coef[21];
extern const double mpx_filter1_coef[21];
extern const double mpx_filter2_coef[21];





#endif
