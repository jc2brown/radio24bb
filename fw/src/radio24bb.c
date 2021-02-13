
#include <stdlib.h>
#include "xpseudo_asm.h"

#include "radio24bb.h"

#include "roe.h"
#include "ioexp.h"

#include "xscugic.h"
#include "xadcps.h"
#include "xadc.h"
#include "xiicps.h"
#include "xspips.h"
#include "scugic.h"
#include "dmaps.h"
#include "iicps.h"
#include "gpiops.h"
#include "uartps.h"
#include "ff.h"
#include "fatfs.h"

#include "sleep.h"
#include "command.h"

#include "aic3204.h"
#include "adc.h"
#include "dac.h"
#include "dds.h"
#include "mpx.h"
#include "usb.h"

#include "spips.h"
#include "playback.h"




#undef trace
#define trace(...)
//#define trace xil_printf







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
#define IICPS1_CLK_RATE 100000

#define I2C_SEL_USB 0
#define I2C_SEL_CODEC 1



#define INA_REGS 0x43C00000UL
#define INB_REGS 0x43C01000UL

#define OUTA_REGS 0x43C02000UL
#define OUTB_REGS 0x43C03000UL

#define DDSA_REGS 0x43C05000UL
#define DDSB_REGS 0x43C06000UL

#define MPX_REGS 0x43C07000UL



/*
void codec_ioexp_intr_handler(void *arg) {
	struct radio24bb *r24bb = (struct radio24bb *)arg;
	u8 port_value;
	ioexp_read_port(r24bb->codec_ioexp, 1, &port_value);
	xil_printf("codec_ioexp intr read port=0x%02X\n", port_value);
}
*/




static char *x = "bb#";


struct radio24bb *make_radio24bb() {	

	trace("make_radio24bb\n");

	struct radio24bb *r24bb = (struct radio24bb *)malloc(sizeof(struct radio24bb));

	r24bb->shell = make_cmd_shell(x, r24bb);
	if (r24bb->shell == NULL) return NULL;

	r24bb->scugic = make_scugic();
	if (r24bb->scugic == NULL) return NULL;

	r24bb->dmaps = make_dmaps();
	if (r24bb->dmaps == NULL) return NULL;

	r24bb->uart = make_uartps();
	if (r24bb->uart == NULL) return NULL;

	r24bb->gpiops = make_gpiops();
	if (r24bb->gpiops == NULL) return NULL;

	r24bb->spips1 = make_spips();
	if (r24bb->spips1 == NULL) return NULL;

	r24bb->iicps0 = make_iicps();
	if (r24bb->iicps0 == NULL) return NULL;

	r24bb->iicps1 = make_iicps();
	if (r24bb->iicps1 == NULL) return NULL;


	r24bb->fatfs = make_fatfs();
	if (r24bb->fatfs == NULL) return NULL;


	r24bb->xadc = (XAdcPs *)malloc(sizeof(XAdcPs));
	if (r24bb->xadc == NULL) return NULL;


	r24bb->ina = make_adc_channel();
	if (r24bb->ina == NULL) return NULL;

	r24bb->inb = make_adc_channel();
	if (r24bb->inb == NULL) return NULL;


	r24bb->outa = make_dac_channel();
	if (r24bb->outa == NULL) return NULL;

	r24bb->outb = make_dac_channel();
	if (r24bb->outb == NULL) return NULL;


	r24bb->codec = make_aic3204();
	if (r24bb->codec == NULL) return NULL;


	r24bb->usb_ioexp_0 = make_ioexp();
	if (r24bb->usb_ioexp_0 == NULL) return NULL;

	r24bb->usb_ioexp_1 = make_ioexp();
	if (r24bb->usb_ioexp_1 == NULL) return NULL;

	r24bb->codec_ioexp = make_ioexp();
	if (r24bb->codec_ioexp == NULL) return NULL;


	r24bb->ddsa = make_dds_channel();
	if (r24bb->ddsa == NULL) return NULL;

	r24bb->ddsb = make_dds_channel();
	if (r24bb->ddsb == NULL) return NULL;


	r24bb->mpx = make_mpx_channel();
	if (r24bb->mpx == NULL) return NULL;


	r24bb->pbka = make_playback();
	if (r24bb->pbka == NULL) return NULL;


	return r24bb;
};






// CODEC IOExp Port 0
#define CODEC_IOEXP_LINE_IN_LED_G    (1<<0)
#define CODEC_IOEXP_LINE_IN_LED_B    (1<<1)
#define CODEC_IOEXP_LINE_OUT_LED_B   (1<<2)
#define CODEC_IOEXP_LINE_OUT_LED_G   (1<<3)
#define CODEC_IOEXP_LINE_OUT_LED_COM (1<<4)
#define CODEC_IOEXP_LINE_OUT_LED_R   (1<<5)
#define CODEC_IOEXP_LINE_IN_LED_COM  (1<<6)
#define CODEC_IOEXP_LINE_IN_LED_R    (1<<7)

// CODEC IOExp Port 1
// #define CODEC_IOEXP_NOT_CONNECTED (1<<0)
#define CODEC_IOEXP_PHONE_OUT_DET    (1<<1)
#define CODEC_IOEXP_LINE_OUT_DET     (1<<2)
#define CODEC_IOEXP_RESET_N          (1<<3)
// #define CODEC_IOEXP_NOT_CONNECTED (1<<4)
// #define CODEC_IOEXP_NOT_CONNECTED (1<<5)
// #define CODEC_IOEXP_NOT_CONNECTED (1<<6)
#define CODEC_IOEXP_LINE_IN_DET      (1<<7)







int set_line_in_led(struct radio24bb *r24bb, int r, int g, int b) {
	u8 port0_value;
	_return_if_error_(ioexp_read_port(r24bb->codec_ioexp, 0, &port0_value));
	port0_value = ~port0_value;
	port0_value &= ~(CODEC_IOEXP_LINE_IN_LED_R | CODEC_IOEXP_LINE_IN_LED_G | CODEC_IOEXP_LINE_IN_LED_B);
	port0_value |= 
		(r ? CODEC_IOEXP_LINE_IN_LED_R : 0) |
		(g ? CODEC_IOEXP_LINE_IN_LED_G : 0) |
		(b ? CODEC_IOEXP_LINE_IN_LED_B : 0);
	port0_value = ~port0_value;
	ioexp_write_port(r24bb->codec_ioexp, 0, port0_value);
	return XST_SUCCESS;
}



int set_line_out_led(struct radio24bb *r24bb, int r, int g, int b) {
	u8 port0_value;
	_return_if_error_(ioexp_read_port(r24bb->codec_ioexp, 0, &port0_value));
	port0_value = ~port0_value;
	port0_value &= ~(CODEC_IOEXP_LINE_OUT_LED_R | CODEC_IOEXP_LINE_OUT_LED_G | CODEC_IOEXP_LINE_OUT_LED_B);
	port0_value |= 
		(r ? CODEC_IOEXP_LINE_OUT_LED_R : 0) |
		(g ? CODEC_IOEXP_LINE_OUT_LED_G : 0) |
		(b ? CODEC_IOEXP_LINE_OUT_LED_B : 0);
	port0_value = ~port0_value;
	_return_if_error_(ioexp_write_port(r24bb->codec_ioexp, 0, port0_value));
	return XST_SUCCESS;
}



int update_codec_ioexp(struct radio24bb *r24bb) {
	u8 port1_value;
	_return_if_error_(ioexp_read_port(r24bb->codec_ioexp, 1, &port1_value));
	set_line_in_led(r24bb, 0, 0, (port1_value & CODEC_IOEXP_LINE_IN_DET));
	set_line_out_led(r24bb, 0, 0, (port1_value & CODEC_IOEXP_LINE_OUT_DET));
	return XST_SUCCESS;
}






// Read VBUS_DET and set or clear blue LED
//
int update_usb_ioexp_0(struct radio24bb *r24bb) {
	// Critical section
	// - need to guard bus_sel (modified by ioexp_read_port  shared by usb_ioexp_0 and usb_ioexp_1
	//Xil_ExceptionDisable(); 

	int ireg = mfcpsr();
	Xil_ExceptionDisable();

	u8 ioe1_port0_value;
	ioexp_read_port(r24bb->usb_ioexp_1, 0, &ioe1_port0_value);

	uint8_t ioe0_port0_value = 
		((!(ioe1_port0_value & USB_IOEXP_1_VBUS_DET_N)) ? USB_IOEXP_0_USB_LED_B : 0) |
		(USB_IOEXP_0_POWER_LED_B);

	ioexp_write_port(r24bb->usb_ioexp_0, 0, ~ioe0_port0_value);

	// Xil_ExceptionEnable();
	mtcpsr(ireg);
	return XST_SUCCESS;
}










int init_radio24bb(struct radio24bb *r24bb, uint32_t regs_addr) {

	trace("init_radio24bb\n");



	_return_if_error_(
		init_scugic(
			r24bb->scugic, 
			XPAR_SCUGIC_0_DEVICE_ID
	));



	_return_if_error_(
		init_gpiops(
			r24bb->gpiops, 
			XPAR_PS7_GPIO_0_DEVICE_ID,
			r24bb->scugic,
			XPAR_XGPIOPS_0_INTR
	));



	r24bb->regs = (struct radio24bb_regs *)regs_addr;
	init_radio24bb_regs(r24bb->regs);




	_return_if_error_(
		init_dmaps(
			r24bb->dmaps,
			r24bb->scugic,
			XPAR_XDMAPS_1_DEVICE_ID,
			XPAR_XDMAPS_0_FAULT_INTR,
			XPAR_XDMAPS_0_DONE_INTR_0,
			playback_dma_done_handler, // ch0 handler
			r24bb->pbka // ch0 callback arg
	));


	_return_if_error_(
		init_uartps(r24bb->uart, 
			r24bb->scugic, 
			XPAR_XUARTPS_0_DEVICE_ID, // Auto-numbered 0 but actual peripheral is PS UART 1
			XPAR_PS7_UART_1_INTR
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
		init_fatfs(r24bb->fatfs
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
			r24bb->spips1,
			r24bb->shell->root_ctx
	));


	_return_if_error_(
		init_ioexp(r24bb->usb_ioexp_0,
			r24bb->iicps1,
			&(r24bb->regs->i2c_sel),
			IOEXP_IICPS, 0x20, I2C_SEL_USB,
			USB_IOEXP_0_PORT0_INPUTS, 
			USB_IOEXP_0_PORT1_INPUTS
	));

	_return_if_error_(
		init_ioexp(r24bb->usb_ioexp_1,
			r24bb->iicps1,
			 &(r24bb->regs->i2c_sel),
			IOEXP_IICPS, 0x21, I2C_SEL_USB,
			USB_IOEXP_1_PORT0_INPUTS,
			USB_IOEXP_1_PORT1_INPUTS
	));

	_return_if_error_(
		init_ioexp(r24bb->codec_ioexp,
			r24bb->iicps1,
			&(r24bb->regs->i2c_sel),
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


	_return_if_error_(
		init_playback(r24bb->pbka, 
			r24bb->scugic, 
			r24bb->dmaps,
			"pbka",
			r24bb->shell->root_ctx,
			XPAR_FABRIC_IRQ_F2P_02_INTR, // buffer not full
			0, // dma channel
			&(r24bb->regs->pbka_data), 
			&(r24bb->regs->pbka_full)
	));


	// init_usb(r24bb->usb);

	r24bb->serial = get_serial(r24bb);

	struct cmd_context *root_ctx = r24bb->shell->root_ctx;
	root_ctx->name[2] = '0' + r24bb->serial;
	root_ctx->arg =  (void*)r24bb;

	init_adc_channel_context("ina", r24bb->ina, root_ctx);
	init_adc_channel_context("inb", r24bb->inb, root_ctx);

	init_dac_channel_context("outa", r24bb->outa, root_ctx);
	init_dac_channel_context("outb", r24bb->outb, root_ctx);

	init_dds_channel_context("ddsa", r24bb->ddsa, root_ctx);
	init_dds_channel_context("ddsb", r24bb->ddsb, root_ctx);

	init_mpx_channel_context("mpx", r24bb->mpx, root_ctx);

	init_usb_channel_context("usb", r24bb, root_ctx);






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
/*
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
*/

	// ioexp_write_port(r24bb->codec_ioexp, 0, 0x00);
	// ioexp_write_port(r24bb->usb_ioexp_0, 0, 0x00);





	_return_if_error_(XScuGic_Connect(r24bb->scugic, XPAR_FABRIC_IRQ_F2P_00_INTR, (Xil_ExceptionHandler)update_usb_ioexp_0, (void *)r24bb));
	XScuGic_Enable(r24bb->scugic, XPAR_FABRIC_IRQ_F2P_00_INTR);

	_return_if_error_(XScuGic_Connect(r24bb->scugic, XPAR_FABRIC_IRQ_F2P_01_INTR, (Xil_ExceptionHandler)update_codec_ioexp, (void *)r24bb));
	XScuGic_Enable(r24bb->scugic, XPAR_FABRIC_IRQ_F2P_01_INTR);




	//Xil_ExceptionEnableMask(XIL_EXCEPTION_IRQ);	
	Xil_ExceptionEnable();

	// Switch to buffered interrupt-driven UART mode
	stdio_uart = r24bb->uart;

	update_usb_ioexp_0(r24bb);
	update_codec_ioexp(r24bb);




	return XST_SUCCESS;
}






int get_serial(struct radio24bb *r24bb) {
	uint8_t port1_value;
	ioexp_read_port(r24bb->usb_ioexp_0, 1, &port1_value);
	int serial = port1_value >> 5;
	return serial;
}


