
#include <stdint.h>
#include <math.h>

#include "dac.h"












void init_dac_channel_regs(struct dac_channel_regs *regs) {

	regs->gain = 256;
	regs->offset = 0;

	regs->mux = 0;
	regs->raw = 0;

	for (int i = 0; i < 21; ++i) {
		regs->filter_coef = (uint32_t)(outa_filter0_coef[i] * (double)(1<<23));
	}

	regs->stat_cfg = 0;
	regs->stat_limit = 0;


	regs->dds_step = 0;

	for (int i = 0; i < 4096; ++i) {
		regs->dds_cfg = (int8_t)(127.0*sin((2.0*3.141*(double)i)/4096.0));

	}

	regs->dds_step = ((1ULL<<32) / 99.99888e6) * 19.7e6;




	regs->att = 0b11;
	regs->amp_en = 1;
	regs->led = 0b001;


	regs->dds_fm_mux = 1;
	regs->dds_fm_raw = 0;
	regs->dds_fm_gain = ((1ULL<<32) / 99.99888e6) * 0.95e3; // 100kHz / 0.5V ADC
	regs->dds_fm_offset = 00000000;


	regs->mux = 4;
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

