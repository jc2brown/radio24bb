
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

#include "aic3204.h"

#include "spips.h"
#include "regs.h"


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

	r24bb->gpiops = make_gpiops();
	r24bb->spips1 = make_spips();
	r24bb->iicps0 = make_iicps();
	r24bb->iicps1 = make_iicps();

	r24bb->xadc = (XAdcPs *)malloc(sizeof(XAdcPs));

	r24bb->codec = make_aic3204();

	r24bb->usb_ioexp_0 = make_ioexp();
	r24bb->usb_ioexp_1 = make_ioexp();
	r24bb->codec_ioexp = make_ioexp();

	return r24bb;
};


int init_radio24bb(struct radio24bb *r24bb, uint32_t regs_addr) {

	xil_printf("init_radio24bb\n");

	_return_if_error_(init_gpiops(r24bb->gpiops, XPAR_PS7_GPIO_0_DEVICE_ID));
	_return_if_error_(init_spips(r24bb->spips1, XPAR_PS7_SPI_1_DEVICE_ID));
	_return_if_error_(init_iicps(r24bb->iicps0, XPAR_PS7_I2C_0_DEVICE_ID, IICPS0_CLK_RATE));
	_return_if_error_(init_iicps(r24bb->iicps1, XPAR_PS7_I2C_1_DEVICE_ID, IICPS1_CLK_RATE));

	// r24bb->adc_ioexp = make_ioexp(IOEXP_GPIO, 0x00, );
	// r24bb->dac_ioexp = make_ioexp(IOEXP_GPIO, 0x00, );


	AUD_RATE = 2;

	_return_if_error_(init_aic3204(
			r24bb->codec,
			r24bb->spips1
	));


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



	// init_adc(r24bb->adc);
	// init_dac(r24bb->dac);
	// init_usb(r24bb->usb);




	r24bb->regs = (struct radio24bb_regs *)regs_addr;
	init_radio24bb_regs(r24bb->regs);




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


