

#ifndef R24BB_H
#define R24BB_H

#include "xgpiops.h"
#include "xadcps.h"
#include "xiicps.h"
#include "xspips.h"

#include "ioexp.h"
#include "aic3204.h"
#include "adc.h"
#include "dac.h"


struct radio24bb {	

	// Zynq peripherals
	XGpioPs *gpiops;
	XSpiPs *spips1;
	XIicPs *iicps0;
	XIicPs *iicps1;
	XAdcPs *xadc;
	
	// Board devices
	struct adc_channel *ina;
	struct adc_channel *inb;

	struct dac_channel *outa;
	struct dac_channel *outb;

	struct dds_channel *ddsa;
	struct dds_channel *ddsb;

	struct mpx_channel *mpx;

	struct aic3204 *codec;

	struct ioexp *adc_ioexp;
	struct ioexp *dac_ioexp;
	struct ioexp *usb_ioexp_0;
	struct ioexp *usb_ioexp_1;
	struct ioexp *codec_ioexp;

	// Misc.
	struct radio24bb_regs *regs;

	int serial;

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
	uint32_t i2c_sel;
}; 




struct radio24bb *make_radio24bb();

int init_radio24bb(struct radio24bb *r24bb, uint32_t regs_addr);




int get_serial(struct radio24bb *r24bb);





#endif
