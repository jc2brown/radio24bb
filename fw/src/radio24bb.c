
#include <stdlib.h>

#include "radio24bb.h"

#include "roe.h"
#include "ioexp.h"

#include "xadcps.h"
#include "xadc.h"
#include "xiicps.h"
#include "iicps.h"





void init_radio24bb_regs(struct radio24bb_regs *regs) {

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


struct radio24bb *make_radio24bb() {	

	xil_printf("make_radio24bb\n");

	struct radio24bb *r24bb = (struct radio24bb *)malloc(sizeof(struct radio24bb));

	r24bb->iicps0 = make_iicps();
	r24bb->iicps1 = make_iicps();

	r24bb->xadc = (XAdcPs *)malloc(sizeof(XAdcPs));

	r24bb->usb_ioexp_0 = make_ioexp();
	r24bb->usb_ioexp_1 = make_ioexp();
	r24bb->codec_ioexp = make_ioexp();

	return r24bb;
};


int init_radio24bb(struct radio24bb *r24bb, uint32_t regs_addr) {

	xil_printf("init_radio24bb\n");

	_return_if_error_(init_iicps(r24bb->iicps0, XPAR_PS7_I2C_0_DEVICE_ID, IICPS0_CLK_RATE));
	_return_if_error_(init_iicps(r24bb->iicps1, XPAR_PS7_I2C_1_DEVICE_ID, IICPS1_CLK_RATE));

	// XIicPs_Config *i2c0_cfg;
	// _return_if_null_(i2c0_cfg = XIicPs_LookupConfig(XPAR_PS7_I2C_0_DEVICE_ID));
	// _return_if_error_(XIicPs_CfgInitialize(r24bb->i2c0, i2c0_cfg, i2c0_cfg->BaseAddress));		
	// _return_if_error_(XIicPs_SelfTest(r24bb->i2c0));
	// _return_if_error_(XIicPs_SetSClk(r24bb->i2c0, 400000));

	// XIicPs_Config *i2c1_cfg;
	// _return_if_null_(i2c1_cfg = XIicPs_LookupConfig(XPAR_PS7_I2C_1_DEVICE_ID));
	// _return_if_error_(XIicPs_CfgInitialize(r24bb->i2c1, i2c1_cfg, i2c1_cfg->BaseAddress));		
	// _return_if_error_(XIicPs_SelfTest(r24bb->i2c1));
	// _return_if_error_(XIicPs_SetSClk(r24bb->i2c1, 400000));



	// r24bb->adc_ioexp = make_ioexp(IOEXP_GPIO, 0x00, );
	// r24bb->dac_ioexp = make_ioexp(IOEXP_GPIO, 0x00, );




	_return_if_error_(init_ioexp(r24bb->usb_ioexp_0,
			r24bb->iicps1,
			IOEXP_IICPS, 0x20, I2C_SEL_USB,
			USB_IOEXP_0_PORT0_INPUTS, 
			USB_IOEXP_0_PORT1_INPUTS
	));

	_return_if_error_(init_ioexp(r24bb->usb_ioexp_1,
			r24bb->iicps1,

			IOEXP_IICPS, 0x21, I2C_SEL_USB,
			USB_IOEXP_1_PORT0_INPUTS,
			USB_IOEXP_1_PORT1_INPUTS
	));

	_return_if_error_(init_ioexp(r24bb->codec_ioexp,
			r24bb->iicps1,
			IOEXP_IICPS, 0x20, I2C_SEL_CODEC,
			CODEC_IOEXP_PORT0_INPUTS,
			CODEC_IOEXP_PORT1_INPUTS
	));



	r24bb->regs = (struct radio24bb_regs *)regs_addr;
	init_radio24bb_regs(r24bb->regs);



	ioexp_write_port(r24bb->codec_ioexp, 0, 0x00);
	ioexp_write_port(r24bb->usb_ioexp_0, 0, 0x00);




	
	return XST_SUCCESS;
}








/*

r24bb
	->adc
		->ina/inb
			->gain
			->offset
			->filt
		->ioexp

	->dac
		->outa/outb
		->ioexp

	->usb
		->ioexp0/ioexp1

	->codec
		->ioexp


*/





int get_serial(struct radio24bb *r24bb) {
	uint8_t port1_value;
	ioexp_read_port(r24bb->usb_ioexp_0, 1, &port1_value);
	int serial = port1_value >> 5;
	return serial;
}


