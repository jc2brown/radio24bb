
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

	uint32_t gain;
	uint32_t offset;
	uint32_t filter_coef;
	uint32_t mux;
	uint32_t raw;
	uint32_t stat_cfg;
	uint32_t stat_min;
	uint32_t stat_max;
	uint32_t stat_limit;
	uint32_t stat_count;
	uint32_t att;
	uint32_t amp_en;
	uint32_t led;

};




// void init_dac_channel_regs(struct dac_channel_regs *regs);


#endif
