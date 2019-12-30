
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

	uint32_t am_mux;
	uint32_t am_raw;
	uint32_t am_gain;
	uint32_t am_offset;

	uint32_t fm_mux;
	uint32_t fm_raw;
	uint32_t fm_gain;
	uint32_t fm_offset;

	uint32_t pm_mux;
	uint32_t pm_raw;
	uint32_t pm_gain;
	uint32_t pm_offset;

	uint32_t mux;

	uint32_t raw;

	uint32_t rom;

	uint32_t step;

	uint32_t prbs_gain;
	uint32_t prbs_offset;

	uint32_t stat_cfg;
	uint32_t stat_min;
	uint32_t stat_max;
	uint32_t stat_limit;
	uint32_t stat_count;

};





#endif
