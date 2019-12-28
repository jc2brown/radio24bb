

#ifndef R24BB_H
#define R24BB_H

#include "xadcps.h"


struct radio24bb {	
	XAdcPs *xadc;
	struct radio24bb_regs *regs;
};


struct radio24bb_regs {	
	uint32_t leds;
	uint32_t usb_wr_data;
	uint32_t usb_wr_full;
	uint32_t usb_rd_data;
	uint32_t usb_rd_empty;
	uint32_t usb_wr_mux;
	uint32_t dac_cfg;
	uint32_t dac_dce;
	uint32_t aud_rate;
	uint32_t usb_wr_push;
	uint32_t usb_led_r;
	uint32_t pwr_led_r;
	uint32_t led0_brightness;
	uint32_t led1_brightness;
	uint32_t serial;
}; 




struct radio24bb *make_radio24bb(uint32_t regs_addr);

void init_radio24bb(struct radio24bb *r24bb);








#endif
