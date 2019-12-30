
#include <stdlib.h>

#include "radio24bb.h"

#include "roe.h"
#include "ioexp.h"

#include "xadcps.h"
#include "xadc.h"
#include "xiicps.h"
#include "xspips.h"
#include "iicps.h"
#include "gpiops.h"

#include "sleep.h"
#include "command.h"

#include "aic3204.h"
#include "adc.h"
#include "dac.h"
#include "dds.h"
#include "mpx.h"

#include "spips.h"
#include "regs.h"


void init_radio24bb_regs(struct radio24bb_regs *regs) {
	regs->leds = 3;
	regs->usb_wr_data = 0;
	regs->usb_wr_mux = 0;
	regs->dac_dce = 0;
	usleep(100000);
	regs->dac_cfg = 0x40;
	regs->aud_rate = 0;
	regs->usb_led_r = 1;
	regs->pwr_led_r = 1;
	regs->led0_brightness = 40000; //(uint32_t)(0.1 * ((1UL<<16)-1));
	regs->led1_brightness = 40000; //(uint32_t)(0.1 * ((1UL<<16)-1));	
}





#define USB_IOEXP_0_PORT0_INPUTS 0x00
#define USB_IOEXP_0_PORT1_INPUTS 0xE0

#define USB_IOEXP_1_PORT0_INPUTS 0x07
#define USB_IOEXP_1_PORT1_INPUTS 0x00

#define CODEC_IOEXP_PORT0_INPUTS 0x00
#define CODEC_IOEXP_PORT1_INPUTS 0x86


#define IICPS0_CLK_RATE 400000
#define IICPS1_CLK_RATE 400000

#define I2C_SEL_USB 0
#define I2C_SEL_CODEC 1



#define INA_REGS 0x43C00000UL
#define INB_REGS 0x43C01000UL

#define OUTA_REGS 0x43C02000UL
#define OUTB_REGS 0x43C03000UL





#define DDSA_REGS 0x43C05000UL
#define DDSB_REGS 0x43C06000UL

#define MPX_REGS 0x43C07000UL



struct radio24bb *make_radio24bb() {	

	xil_printf("make_radio24bb\n");

	struct radio24bb *r24bb = (struct radio24bb *)malloc(sizeof(struct radio24bb));

	r24bb->gpiops = make_gpiops();
	r24bb->spips1 = make_spips();
	r24bb->iicps0 = make_iicps();
	r24bb->iicps1 = make_iicps();

	r24bb->xadc = (XAdcPs *)malloc(sizeof(XAdcPs));

	r24bb->ina = make_adc_channel();
	r24bb->inb = make_adc_channel();

	r24bb->outa = make_dac_channel();
	r24bb->outb = make_dac_channel();

	r24bb->codec = make_aic3204();

	r24bb->usb_ioexp_0 = make_ioexp();
	r24bb->usb_ioexp_1 = make_ioexp();
	r24bb->codec_ioexp = make_ioexp();

	r24bb->ddsa = make_dds_channel();
	r24bb->ddsb = make_dds_channel();

	r24bb->mpx = make_mpx_channel();

	return r24bb;
};


int init_radio24bb(struct radio24bb *r24bb, uint32_t regs_addr) {


	r24bb->regs = (struct radio24bb_regs *)regs_addr;
	init_radio24bb_regs(r24bb->regs);


	xil_printf("init_radio24bb\n");

	_return_if_error_(
		init_gpiops(r24bb->gpiops, 
			XPAR_PS7_GPIO_0_DEVICE_ID
	));

	_return_if_error_(
		init_spips(r24bb->spips1, 
			XPAR_PS7_SPI_1_DEVICE_ID
	));

	_return_if_error_(
		init_iicps(r24bb->iicps0, 
			XPAR_PS7_I2C_0_DEVICE_ID, IICPS0_CLK_RATE
	));

	_return_if_error_(
		init_iicps(r24bb->iicps1, 
			XPAR_PS7_I2C_1_DEVICE_ID, IICPS1_CLK_RATE
	));



	_return_if_error_(
		init_adc_channel(r24bb->ina, 
			INA_REGS
	));

	_return_if_error_(
		init_adc_channel(r24bb->inb, 
			INB_REGS
	));


	_return_if_error_(
		init_dac_channel(r24bb->outa, 
			OUTA_REGS
	));

	_return_if_error_(
		init_dac_channel(r24bb->outb, 
			OUTB_REGS
	));



	_return_if_error_(
		init_aic3204(r24bb->codec,
			r24bb->spips1
	));


	_return_if_error_(
		init_ioexp(r24bb->usb_ioexp_0,
			r24bb->iicps1, &(r24bb->regs->i2c_sel),
			IOEXP_IICPS, 0x20, I2C_SEL_USB,
			USB_IOEXP_0_PORT0_INPUTS, 
			USB_IOEXP_0_PORT1_INPUTS
	));

	_return_if_error_(
		init_ioexp(r24bb->usb_ioexp_1,
			r24bb->iicps1, &(r24bb->regs->i2c_sel),
			IOEXP_IICPS, 0x21, I2C_SEL_USB,
			USB_IOEXP_1_PORT0_INPUTS,
			USB_IOEXP_1_PORT1_INPUTS
	));

	_return_if_error_(
		init_ioexp(r24bb->codec_ioexp,
			r24bb->iicps1, &(r24bb->regs->i2c_sel),
			IOEXP_IICPS, 0x20, I2C_SEL_CODEC,
			CODEC_IOEXP_PORT0_INPUTS,
			CODEC_IOEXP_PORT1_INPUTS
	));



	_return_if_error_(
		init_dds_channel(r24bb->ddsa,
			DDSA_REGS			
	));

	_return_if_error_(
		init_dds_channel(r24bb->ddsb,
			DDSB_REGS			
	));



	_return_if_error_(
		init_mpx_channel(r24bb->mpx,
			MPX_REGS			
	));






	// init_usb(r24bb->usb);

	r24bb->serial = get_serial(r24bb);


	get_root_context()->name[2] = '0' + r24bb->serial;

	init_adc_channel_context("ina", r24bb->ina, NULL);
	init_adc_channel_context("inb", r24bb->inb, NULL);

	init_dac_channel_context("outa", r24bb->outa, NULL);
	init_dac_channel_context("outb", r24bb->outb, NULL);

	init_dds_channel_context("ddsa", r24bb->ddsa, NULL);
	init_dds_channel_context("ddsb", r24bb->ddsb, NULL);

	init_mpx_channel_context("mpx", r24bb->mpx, NULL);




	XGpioPs_SetDirection(r24bb->gpiops, 0, 0x0);
	XGpioPs_SetOutputEnable(r24bb->gpiops, 0, 0x0);


	XGpioPs_SetDirection(r24bb->gpiops, 1, 0xFFFFFFFF);
	XGpioPs_SetDirection(r24bb->gpiops, 2, 0xFFFFFFFF);
	XGpioPs_SetDirection(r24bb->gpiops, 3, 0xFFFFFFFF);

	XGpioPs_SetOutputEnable(r24bb->gpiops, 1, 0xFFFFFFFF);
	XGpioPs_SetOutputEnable(r24bb->gpiops, 2, 0xFFFFFFFF);
	XGpioPs_SetOutputEnable(r24bb->gpiops, 3, 0xFFFFFFFF);


	/*
	XGpioPs_Write(gpiops_ptr, 0, 0xFFFFFFFF);
	XGpioPs_Write(gpiops_ptr, 1, 0xFFFFFFFF);
	XGpioPs_Write(gpiops_ptr, 2, 0xFFFFFFFF);
	XGpioPs_Write(gpiops_ptr, 3, 0xFFFFFFFF);

*/

	XGpioPs_Write(r24bb->gpiops, 1, 0x0);
	XGpioPs_Write(r24bb->gpiops, 2, 0x00);
	XGpioPs_Write(r24bb->gpiops, 3, 0x00);
	usleep(500000);
	XGpioPs_Write(r24bb->gpiops, 2, 0xFFFFFFFF);
	XGpioPs_Write(r24bb->gpiops, 3, 0xFFFFFFFF);


	XGpioPs_WritePin(r24bb->gpiops, 54, 1);	// INB ATT0
	XGpioPs_WritePin(r24bb->gpiops, 55, 1);	// INB ATT1

	XGpioPs_WritePin(r24bb->gpiops, 58, 1);  // INA ATT0
	XGpioPs_WritePin(r24bb->gpiops, 59, 1);  // INA ATT1


	XGpioPs_WritePin(r24bb->gpiops, 90, 1);	// USB_RESET_N


	ioexp_write_port(r24bb->codec_ioexp, 0, 0x00);
	ioexp_write_port(r24bb->usb_ioexp_0, 0, 0x00);

	return XST_SUCCESS;
}






int get_serial(struct radio24bb *r24bb) {
	uint8_t port1_value;
	ioexp_read_port(r24bb->usb_ioexp_0, 1, &port1_value);
	int serial = port1_value >> 5;
	return serial;
}


