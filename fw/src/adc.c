
#include <stdint.h>

#include "adc.h"





/*
struct adc_channel_stats {
	uint32_t cfg;
	uint32_t min;
	uint32_t max;
	uint32_t limit;
	uint32_t count;
}; 

*/








void init_adc_channel_regs(struct adc_channel_regs *regs) {

	regs->gain = 256;
	regs->offset = 0;

	for (int i = 0; i < 21; ++i) {
		//regs->filter_coef = (uint32_t)(ina_filter2_coef[20-i] * (double)(1<<23));
		regs->filter_coef = (uint32_t)(ina_filter0_coef[i] * (double)(1<<23));
	}

	regs->stat_cfg = 0;
	regs->stat_limit = 0;


	regs->att = 0b00;
	regs->amp_en = 1;
	regs->led = 0b001;

}



/*

localparam REG_GAIN = 12'h000;
localparam REG_OFFSET = 12'h04;
localparam REG_FILTER_COEF = 12'h08;
localparam REG_STAT_CFG   = 12'h0C;
localparam REG_STAT_MIN   = 12'h10;
localparam REG_STAT_MAX   = 12'h14;
localparam REG_STAT_LIMIT = 12'h18;
localparam REG_STAT_COUNT = 12'h1C;

*/

