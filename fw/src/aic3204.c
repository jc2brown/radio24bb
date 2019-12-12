

#include "xspips.h"

#include "spi.h"


#include "aic3204.h"




void transfer(uint8_t addr, uint8_t data_in, uint8_t *data_out) {
	uint8_t outbuf[2] = {addr, data_in};
	uint8_t inbuf[2] = {0xAA, 0xAA};
	XSpiPs_SetSlaveSelect(xspips_ptr, 0x0);
	XSpiPs_PolledTransfer(xspips_ptr, outbuf, inbuf, 2);
	XSpiPs_SetSlaveSelect(xspips_ptr, 0x7);
	if (data_out != NULL) {
		*data_out = inbuf[1];
	}
}





void select_page(uint8_t page) {
	static uint8_t _page = 0xFF;
	if (page != _page) {
		xil_printf("page=%d\n", page);
		transfer(0, page, NULL);
		_page = page;
	}
}



void read_register(uint8_t page, uint8_t reg, uint8_t *data_out) {
	select_page(page);
	reg = (reg << 1) | 0x01;
	transfer(reg, 0, data_out);
	xil_printf("rd reg %d: %d\n", reg>>1, *data_out);

}


void write_register(uint8_t page, uint8_t reg, uint8_t data_in) {
	select_page(page);
	reg = reg << 1;
	transfer(reg, data_in, NULL);
	xil_printf("wr reg %d <= %d\n", reg>>1, data_in);
}



#include <sleep.h>


void init_aic3204() {

	uint8_t buf;
	//xil_printf("sw reset\n");

	write_register(0, 1, 1); // SW reset
	usleep(100000);



	// write_register(0, 5, 0xFF); 
	// read_register(0, 5, &buf); 



	for (int i = 0; i < 128; ++i) {
		read_register(0, i, &buf); 

	}

//	write_register(0, 86, 1);
	// read_register(0, 86, &buf); 

	// write_register(0, 4, 0);
	//xil_printf("wr1: 0x%X\n", 0);
	// read_register(0, 4, &buf);
	//xil_printf("rd1: 0x%X\n", buf);

	// write_register(0, 4, 1);
	//xil_printf("wr2: 0x%X\n", 1);
	// read_register(0, 4, &buf);
	//xil_printf("rd2: 0x%X\n", buf);

}



