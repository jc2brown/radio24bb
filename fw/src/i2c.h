
#include "xparameters.h"
#include "sleep.h"
#include "xiicps.h"
#include "xil_printf.h"
#include "xplatform_info.h"

#define IIC_SCLK_RATE		100000


#define I2C_TIMEOUT 100 //ms


s32 i2c_init(void);
int i2c_config(void);
int i2c_selftest(void);
XIicPs *get_xiicps(void);
s32 i2c_write(u8 addr, u8 *WriteBuffer, u16 ByteCount);
s32 i2c_read8(u8 bus_addr, u8 reg_addr, u8 *BufferPtr, u16 ByteCount);
s32 i2c_read16(u8 bus_addr, u16 reg_addr, u8 *BufferPtr, u16 ByteCount);
int i2c_wait_for_bus(int timeout);
