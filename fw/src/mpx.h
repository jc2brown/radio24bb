
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

	volatile uint32_t pilot_gain;
 
	volatile uint32_t rom;
 
	volatile uint32_t step;
 
	volatile uint32_t stat_cfg;
	volatile uint32_t stat_min;
	volatile uint32_t stat_max;
	volatile uint32_t stat_limit;
	volatile uint32_t stat_count;
 
	volatile uint32_t filter_coef;

	volatile uint32_t mux;

	volatile uint32_t preemph_en;

	volatile int32_t b0;
	volatile int32_t b1;
	volatile int32_t b2;
	volatile int32_t a1;
	volatile int32_t a2;

};



extern const double mpx_filter0_coef[21];
extern const double mpx_filter1_coef[21];
extern const double mpx_filter2_coef[21];





#endif
