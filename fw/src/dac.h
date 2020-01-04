
#ifndef DAC_H
#define DAC_H

#include "command.h"

struct dac_channel {
	struct dac_channel_regs *regs;
};





struct dac_channel *make_dac_channel();

int init_dac_channel(struct dac_channel *channel, uint32_t regs_addr);

void init_dac_channel_context(char *name, void *arg, struct cmd_context *parent_ctx) ;

void dac_stat(struct dac_channel *channel);


extern const double outa_filter0_coef[21];
/*
extern static double outa_filter1_coef[21];
extern static double outa_filter2_coef[21];
extern static double outa_filter3_coef[21];
*/






struct dac_channel_regs {

	volatile uint32_t gain;
	volatile uint32_t offset;
	volatile uint32_t filter_coef;
	volatile uint32_t mux;
	volatile uint32_t raw;
	volatile uint32_t stat_cfg;
	volatile uint32_t stat_min;
	volatile uint32_t stat_max;
	volatile uint32_t stat_limit;
	volatile uint32_t stat_count;
	volatile uint32_t att;
	volatile uint32_t amp_en;
	volatile uint32_t led;

};




// void init_dac_channel_regs(struct dac_channel_regs *regs);


#endif
