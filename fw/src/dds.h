
#ifndef DDS_H
#define DDS_H

#include "command.h"

struct dds_channel {
	struct dds_channel_regs *regs;
};





struct dds_channel *make_dds_channel();

int init_dds_channel(struct dds_channel *channel, uint32_t regs_addr);

void init_dds_channel_context(char *name, void *arg, struct cmd_context *parent_ctx) ;





struct dds_channel_regs {

	volatile uint32_t am_mux;
	volatile uint32_t am_raw;
	volatile uint32_t am_gain;
	volatile uint32_t am_offset;
 
	volatile uint32_t fm_mux;
	volatile uint32_t fm_raw;
	volatile uint32_t fm_gain;
	volatile uint32_t fm_offset;
 
	volatile uint32_t pm_mux;
	volatile uint32_t pm_raw;
	volatile uint32_t pm_gain;
	volatile uint32_t pm_offset;
 
	volatile uint32_t mux;
 
	volatile uint32_t raw;
 
	volatile uint32_t rom;
 
	volatile uint32_t step;
 
	volatile uint32_t prbs_gain;
	volatile uint32_t prbs_offset;
 
	volatile uint32_t stat_cfg;
	volatile uint32_t stat_min;
	volatile uint32_t stat_max;
	volatile uint32_t stat_limit;
	volatile uint32_t stat_count;

};





#endif
