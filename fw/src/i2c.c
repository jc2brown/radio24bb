


/*
#include "xiicps.h"
#include "roe.h"
#include "i2c.h"


static XIicPs xiicps;
static int i2c_inited = 0;


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





s32 i2c_read8(u8 bus_addr, u8 reg_addr, u8 *BufferPtr, u16 ByteCount) {
	u32 WrBfrOffset;
	u8 WriteBuffer[1];
	WriteBuffer[0] = reg_addr;
	WrBfrOffset = 1;
	_return_if_error_(i2c_write(bus_addr, WriteBuffer, WrBfrOffset));
	_return_if_error_(XIicPs_MasterRecvPolled(get_xiicps(), BufferPtr, ByteCount, bus_addr));
	while (XIicPs_BusIsBusy(get_xiicps()));
	return XST_SUCCESS;
}

s32 i2c_read16(u8 bus_addr, u16 reg_addr, u8 *BufferPtr, u16 ByteCount) {
	u32 WrBfrOffset;
	u8 WriteBuffer[2];
	WriteBuffer[0] = (u8) (reg_addr >> 8);
	WriteBuffer[1] = (u8) (reg_addr);
	WrBfrOffset = 2;
	_return_if_error_(i2c_write(bus_addr, WriteBuffer, WrBfrOffset));
	_return_if_error_(XIicPs_MasterRecvPolled(get_xiicps(), BufferPtr, ByteCount, bus_addr));
	while (XIicPs_BusIsBusy(get_xiicps()));
	return XST_SUCCESS;
}

*/