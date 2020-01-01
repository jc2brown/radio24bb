
#ifndef ADC_H
#define ADC_H


#include "command.h"


struct adc_channel {
	struct adc_channel_regs *regs;
};


struct adc_channel *make_adc_channel();

int init_adc_channel(struct adc_channel *channel, uint32_t regs_addr);

void init_adc_channel_context(char *name, void *arg, struct cmd_context *parent_ctx) ;




extern const double ina_filter0_coef[21];
/*
extern static double ina_filter1_coef[21] ;
extern static double ina_filter2_coef[21];
extern static double ina_filter3_coef[21];
*/







struct adc_channel_regs {

	uint32_t gain;
	uint32_t offset;
	uint32_t filter_coef;
	uint32_t stat_cfg;
	uint32_t stat_min;
	uint32_t stat_max;
	uint32_t stat_limit;
	uint32_t stat_count;
	uint32_t att;
	uint32_t amp_en;
	uint32_t led;

};




void adc_stat(struct adc_channel *channel);
#endif
