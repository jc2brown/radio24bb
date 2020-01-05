

#ifndef R24BB_H
#define R24BB_H

#include "xscugic.h"
#include "xuartps.h"
#include "xgpiops.h"
#include "xadcps.h"
#include "xiicps.h"
#include "xspips.h"
#include "ff.h"

#include "queue.h"
#include "command.h"
#include "ioexp.h"
#include "aic3204.h"
#include "adc.h"
#include "dac.h"
#include "playback.h"


struct radio24bb {	

	int serial;

	// System
	struct cmd_shell *shell;
	struct radio24bb_regs *regs;

	// Zynq peripherals
	XScuGic *scugic;
	struct uartps *uart;
	XGpioPs *gpiops;
	XSpiPs *spips1;
	XIicPs *iicps0;
	XIicPs *iicps1;
	XAdcPs *xadc;

	// File system
	FATFS *fatfs;
	
	// Board devices
	struct adc_channel *ina;
	struct adc_channel *inb;
	struct dac_channel *outa;
	struct dac_channel *outb;
	struct aic3204 *codec;
	struct ioexp *adc_ioexp;
	struct ioexp *dac_ioexp;
	struct ioexp *usb_ioexp_0;
	struct ioexp *usb_ioexp_1;
	struct ioexp *codec_ioexp;

	// DSP devices
	struct dds_channel *ddsa;
	struct dds_channel *ddsb;
	struct mpx_channel *mpx;
		
	struct playback *pbka;

	// Misc.
};



struct radio24bb_regs {	
	volatile uint32_t leds;
	volatile uint32_t usb_wr_data;
	volatile uint32_t usb_wr_full;
	volatile uint32_t usb_rd_data;
	volatile uint32_t usb_rd_empty;
	volatile uint32_t usb_wr_mux;
	volatile uint32_t dac_cfg;
	volatile uint32_t dac_dce;
	volatile uint32_t aud_rate;
	volatile uint32_t usb_wr_push;
	volatile uint32_t usb_led_r;
	volatile uint32_t pwr_led_r;
	volatile uint32_t led0_brightness;
	volatile uint32_t led1_brightness;
	volatile uint32_t serial;
	volatile uint32_t i2c_sel;
	volatile uint32_t pbka_data;
	volatile uint32_t pbka_full;
	volatile uint32_t audout_mux;
}; 




struct radio24bb *make_radio24bb();

int init_radio24bb(struct radio24bb *r24bb, uint32_t regs_addr);




int get_serial(struct radio24bb *r24bb);





#endif
