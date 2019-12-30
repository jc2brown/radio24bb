
#include <stdlib.h>

#include "roe.h"
#include "iicps.h"

#include "ioexp.h"



#define IOEXP_REG_IN0 0x00
#define IOEXP_REG_IN1 0x01

#define IOEXP_REG_OUT0 0x02
#define IOEXP_REG_OUT1 0x03

#define IOEXP_REG_CFG0 0x06
#define IOEXP_REG_CFG1 0x07

#define IOEXP_REG_INTMASK0 0x4A
#define IOEXP_REG_INTMASK1 0x4B





struct ioexp *make_ioexp() {
	xil_printf("make_ioexp\n");
	struct ioexp *ioe = (struct ioexp *)malloc(sizeof(struct ioexp));
	return ioe;
}


int ioexp_write_register(struct ioexp *ioe, uint8_t reg, uint8_t value) {
	xil_printf("ioexp_write_register  bus_sel=%d  bus_addr=0x%02X  reg=0x%02X  value=0x%02X\n", ioe->bus_sel, ioe->bus_addr, reg, value);
	*(ioe->bus_sel_ptr) = ioe->bus_sel;
	switch (ioe->if_type) {
	case IOEXP_IICPS:
		_return_if_error_(iicps_reg_write_1byte(ioe->iicps, ioe->bus_addr, reg, value));		
		return XST_SUCCESS;
	// case IOEXP_GPIO:
	// 	xil_printf("TODO!\n");		
	// 	break;
	default:
		xil_printf("ERROR: ioexp_write_register: unsupported if_type: %d\n", ioe->if_type);
		return XST_NO_FEATURE;
	}
}


int ioexp_read_register(struct ioexp *ioe, uint8_t reg, uint8_t *value) {
	xil_printf("ioexp_read_register  bus_sel=%d  bus_addr=0x%02X  reg=0x%02X  \n", ioe->bus_sel, ioe->bus_addr, reg);
	*(ioe->bus_sel_ptr) = ioe->bus_sel;
	switch (ioe->if_type) {
	case IOEXP_IICPS:
		_return_if_error_(iicps_reg_read_1byte(ioe->iicps, ioe->bus_addr, reg, value));		
		return XST_SUCCESS;
	// case IOEXP_GPIO:
	// 	xil_printf("TODO!\n");		
	// 	break;
	default:
		xil_printf("ERROR: ioexp_write_register: unsupported if_type: %d\n", ioe->if_type);
		return XST_NO_FEATURE;
	}
}






int init_ioexp(
		struct ioexp *ioe, 
		XIicPs *iicps,
		uint32_t *bus_sel_ptr,
		int if_type, 
		uint8_t bus_addr, 
		int bus_sel,
		uint8_t port0_inputs, 
		uint8_t port1_inputs
) {

	xil_printf("init_ioexp: if_type=%d  bus_addr=0x%02X\n", if_type, bus_addr);
	
	ioe->iicps = iicps;
	ioe->bus_sel_ptr = bus_sel_ptr;

	if (! (if_type == IOEXP_IICPS /*|| if_type == IOEXP_GPIO*/) ) {
		xil_printf("XST_INVALID_PARAM\n");
		return XST_INVALID_PARAM;
	}
	ioe->if_type = if_type;
	ioe->bus_sel = bus_sel;

	if (ioe->if_type == IOEXP_IICPS) {
		if (! (bus_addr == 0x20 || bus_addr == 0x21) ) {
			xil_printf("XST_INVALID_PARAM\n");
			return XST_INVALID_PARAM;
		}
		ioe->bus_addr = bus_addr;
	}

	switch (ioe->if_type) {
	case IOEXP_IICPS:
		_return_if_error_(ioexp_write_register(ioe, IOEXP_REG_CFG0, port0_inputs));
		_return_if_error_(ioexp_write_register(ioe, IOEXP_REG_CFG1, port1_inputs));
		return XST_SUCCESS;
	// case IOEXP_GPIO:
	// 	xil_printf("TODO!\n");		
	// 	break;
	}
	
	return XST_SUCCESS;
}





int ioexp_read_port(struct ioexp *ioe, int port, uint8_t *value) {
	if (! (port == 0 || port == 1) ) {
		return XST_INVALID_PARAM;
	}
	switch (ioe->if_type) {
	case IOEXP_IICPS:
		_return_if_error_(ioexp_read_register(ioe, 0x00+port, value));		
		return XST_SUCCESS;
	// case IOEXP_GPIO:
	// 	xil_printf("TODO!\n");		
	// 	break;
	}
	return XST_NO_FEATURE;
}





int ioexp_write_port(struct ioexp *ioe, int port, uint8_t value) {
	if (! (port == 0 || port == 1) ) {
		return XST_INVALID_PARAM;
	}
	switch (ioe->if_type) {
	case IOEXP_IICPS:
		_return_if_error_(ioexp_write_register(ioe, 0x02+port, value));		
		return XST_SUCCESS;
	// case IOEXP_GPIO:
	// 	xil_printf("TODO!\n");		
	// 	break;
	}
	return XST_NO_FEATURE;
}



/*
int ioexp_read_pin(struct ioexp *ioe, int port) {
	switch (ioe->if_type) {
	case IOEXP_IICPS:
		i2c_read(ioe->iicps, port);		
		break;
	// case IOEXP_GPIO:
	// 	xil_printf("TODO!\n");		
	// 	break;
	}
	xil_printf("ERROR: ioexp_read: unsupported if_type: %d\n", ioe->if_type);	
}
*/


int ioexp_write(struct ioexp *ioe, int port, uint8_t value, uint8_t mask) {
	uint8_t port_value;
	_return_if_error_(ioexp_read_port(ioe, port, &port_value));
	port_value &= ~mask;
	port_value |= (value & mask);
	_return_if_error_(ioexp_write_port(ioe, port, port_value));
	return XST_SUCCESS;
}



/*
uint8_t ioexp_write_pin(struct ioexp *ioe, int port, int pin_num, int pin_value) {
	switch (ioe->if_type) {
	case IOEXP_IICPS:

		ioexp_write(ioe, port, pin);

		i2c_read(ioe->iicps, port);		
		break;
	// case IOEXP_GPIO:
	// 	xil_printf("TODO!\n");		
	// 	break;
	}
	xil_printf("ERROR: ioexp_read: unsupported if_type: %d\n", ioe->if_type);	
}
*/