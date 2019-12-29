






#include "xiicps.h"
#include "roe.h"
#include "iicps.h"
#include "sleep.h"



XIicPs *make_iicps() {
	xil_printf("make_iicps\n");
	XIicPs *iicps = (XIicPs *)malloc(sizeof(XIicPs));
	return iicps;
}


int init_iicps(XIicPs *iicps, int device_id, int clk_rate) {
	xil_printf("init_iicps\n");
	XIicPs_Config *iicps_cfg = XIicPs_LookupConfig(device_id);
	_return_if_null_(iicps_cfg);
	_return_if_error_(XIicPs_CfgInitialize(iicps, iicps_cfg, iicps_cfg->BaseAddress));
	_return_if_error_(XIicPs_SelfTest(iicps));
	_return_if_error_(XIicPs_SetSClk(iicps, clk_rate));
	return XST_SUCCESS;	
}






int iicps_wait_for_bus(XIicPs *iicps, int timeout) {
	for ( int i = 0; i < timeout; ++i ) {
		if ( ! XIicPs_BusIsBusy(iicps) ) {
			return XST_SUCCESS;
		}
		usleep(1000);
	}
	return XST_IIC_BUS_BUSY;
}


s32 iicps_write(XIicPs *iicps, u8 bus_addr, u8 *WriteBuffer, u16 ByteCount) {
	_return_if_null_(iicps);
	_return_if_error_(XIicPs_MasterSendPolled(iicps, WriteBuffer, ByteCount, bus_addr), "&WrBuf=%p, ByteCount=%d, SlvAddr=0x%X\n", &WriteBuffer, ByteCount, bus_addr);
	// TODO: timeout?

	// while (XIicPs_BusIsBusy(iicps));

	_return_if_error_(iicps_wait_for_bus(iicps, 100));

	return XST_SUCCESS;
}


s32 iicps_write_1byte(XIicPs *iicps, u8 bus_addr, u8 byte0) {
	_return_if_error_(XIicPs_MasterSendPolled(iicps, &byte0, 1, bus_addr));
	// TODO: timeout?
	return XST_SUCCESS;
}

s32 iicps_write_2bytes(XIicPs *iicps, u8 bus_addr, u8 byte0, uint8_t byte1) {
	xil_printf("iicps_write_2bytes\n");
	uint8_t buf[2] = { byte0, byte1 };
	// _return_if_error_(XIicPs_MasterSendPolled(iicps, buf, 2, bus_addr));
	_return_if_error_(iicps_write(iicps, bus_addr, buf, 2));
	// TODO: timeout?
	return XST_SUCCESS;
}

s32 iicps_write_3bytes(XIicPs *iicps, u8 bus_addr, u8 byte0, uint8_t byte1, uint8_t byte2) {
	uint8_t buf[3] = { byte0, byte1, byte2 };
	_return_if_error_(XIicPs_MasterSendPolled(iicps, buf, 3, bus_addr));
	// TODO: timeout?
	return XST_SUCCESS;
}

s32 iicps_reg_write_1byte(XIicPs *iicps, u8 bus_addr, u8 reg_addr, u8 byte0) {
	return iicps_write_2bytes(iicps, bus_addr, reg_addr, byte0);
}

s32 iicps_reg_write_2bytes(XIicPs *iicps, u8 bus_addr, u8 reg_addr, u8 byte0, u8 byte1) {
	return iicps_write_3bytes(iicps, bus_addr, reg_addr, byte0, byte1);
}




s32 iicps_read(XIicPs *iicps, u8 bus_addr, u8 *buf, u16 num_bytes) {
	_return_if_error_(XIicPs_MasterRecvPolled(iicps, buf, num_bytes, bus_addr));
	// TODO: timeout?
	while (XIicPs_BusIsBusy(iicps));
	return XST_SUCCESS;
}


s32 iicps_reg_read(XIicPs *iicps, u8 bus_addr, u8 reg_addr, u8 *buf, u16 num_bytes) {
	_return_if_error_(iicps_write_1byte(iicps, bus_addr, reg_addr));
	_return_if_error_(iicps_read(iicps, bus_addr, buf, num_bytes));
	return XST_SUCCESS;
}

s32 iicps_reg_read_1byte(XIicPs *iicps, u8 bus_addr, u8 reg_addr, u8 *byte0) {
	return iicps_reg_read(iicps, bus_addr, reg_addr, byte0, 1);
}

s32 iicps_reg_read_2bytes(XIicPs *iicps, u8 bus_addr, u8 reg_addr, u8 *byte0, u8 *byte1) {
	uint8_t buf[2];
	_return_if_error_(iicps_reg_read(iicps, bus_addr, reg_addr, buf, 2));
	*byte0 = buf[0];
	*byte1 = buf[1];
	return XST_SUCCESS;
}




/*
s32 i2c_read16_2(XIicPs *xiic2ps, u8 bus_addr, u16 reg_addr, u8 *BufferPtr, u16 ByteCount) {
	u32 WrBfrOffset;
	u8 WriteBuffer[2];
	WriteBuffer[0] = (u8) (reg_addr >> 8);
	WriteBuffer[1] = (u8) (reg_addr);
	WrBfrOffset = 2;
	_return_if_error_(i2c_write2(xiic2ps, bus_addr, WriteBuffer, WrBfrOffset));
	_return_if_error_(XIicPs_MasterRecvPolled(xiic2ps, BufferPtr, ByteCount, bus_addr));
	while (XIicPs_BusIsBusy(xiic2ps));
	return XST_SUCCESS;
}
*/


/*

s32 i2c_init() {
	if ( ! i2c_inited ) {
		XIicPs_Config *ConfigPtr = XIicPs_LookupConfig(XPAR_PS7_I2C_0_DEVICE_ID);
		if (ConfigPtr == NULL) {
			_return_(XST_FAILURE, "XIicPs_LookupConfig failed\n")
		}
		_return_if_error_(XIicPs_CfgInitialize(&xiicps, ConfigPtr, ConfigPtr->BaseAddress));
		i2c_inited = 1;
	}
	return XST_SUCCESS;
}



int i2c_config() {
	_return_if_error_(XIicPs_SetSClk(&xiicps, IIC_SCLK_RATE));
	return XST_SUCCESS;
}



int i2c_selftest() {
	_return_if_error_(XIicPs_SelfTest(get_xiicps()));
	return XST_SUCCESS;
}



int i2c_wait_for_bus(int timeout) {
	for ( int i = 0; i < timeout; ++i ) {
		if ( ! XIicPs_BusIsBusy(get_xiicps()) ) {
			return XST_SUCCESS;
		}
		usleep(1000);
	}
	return XST_IIC_BUS_BUSY;
}



XIicPs *get_xiicps() {
	return &xiicps;
}



s32 i2c_write(u8 bus_addr, u8 *WriteBuffer, u16 ByteCount) {
	_return_if_error_(XIicPs_MasterSendPolled(get_xiicps(), WriteBuffer, ByteCount, bus_addr), "&WrBuf=%p, ByteCount=%d, SlvAddr=0x%X\n", &WriteBuffer, ByteCount, bus_addr);
	while (XIicPs_BusIsBusy(get_xiicps()));
	return XST_SUCCESS;
}




*/










