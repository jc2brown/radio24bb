
#ifndef MPX_H
#define MPX_H

#include "command.h"

struct mpx_channel {
	struct mpx_channel_regs *regs;
};





struct mpx_channel *make_mpx_channel(uint32_t regs_addr);

void init_mpx_channel(struct mpx_channel *channel);

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



static double mpx_filter0_coef[21] = {
        0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0
};

static double mpx_filter1_coef[21] = {
        0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0
};

// 50us preemph
static double mpx_filter2_coef[21] = {
	/*
        -0.0021517533, 0.012997414, -0.019828710,
	0.032182135, -0.044028814, 0.054945656, -0.072606134, 0.065872348, -0.096650200,
	-0.12731812, 0.49517235, -0.12731812, -0.096650200, 0.065872348, -0.072606134,
	0.054945656, -0.044028814, 0.032182135, -0.019828710, 0.012997414, -0.0021517533
	*/
	-0.00085693960, -0.0019427534, -0.00069509940,
	-0.0038411481, -0.00083768112, -0.0083490695, -0.0012431629, -0.023540759, -0.0016748405,
	-0.20683919, 0.50280357, -0.20683919, -0.0016748405, -0.023540759, -0.0012431629,
	-0.0083490695, -0.00083768112, -0.0038411481, -0.00069509940, -0.0019427534, -0.00085693960
};





void init_mpx_channel_regs(struct mpx_channel_regs *regs);


#endif
