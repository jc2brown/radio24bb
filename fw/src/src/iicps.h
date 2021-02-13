

#ifndef IICPS_H
#define IICPS_H


#include "xiicps.h"
#include "iicps.h"


XIicPs *make_iicps();
int init_iicps(XIicPs *iicps, int device_id, int clk_rate);


s32 iicps_write(XIicPs *iicps, u8 bus_addr, u8 *WriteBuffer, u16 ByteCount);
s32 iicps_write_1byte(XIicPs *iicps, u8 bus_addr, u8 byte0);
s32 iicps_write_2bytes(XIicPs *iicps, u8 bus_addr, u8 byte0, uint8_t byte1);
s32 iicps_write_3bytes(XIicPs *iicps, u8 bus_addr, u8 byte0, uint8_t byte1, uint8_t byte2);
s32 iicps_reg_write_1byte(XIicPs *iicps, u8 bus_addr, u8 reg_addr, u8 byte0);
s32 iicps_reg_write_2bytes(XIicPs *iicps, u8 bus_addr, u8 reg_addr, u8 byte0, u8 byte1);

s32 iicps_read(XIicPs *iicps, u8 bus_addr, u8 *buf, u16 num_bytes);
s32 iicps_reg_read(XIicPs *iicps, u8 bus_addr, u8 reg_addr, u8 *buf, u16 num_bytes);
s32 iicps_reg_read_1byte(XIicPs *iicps, u8 bus_addr, u8 reg_addr, u8 *byte0);
s32 iicps_reg_read_2bytes(XIicPs *iicps, u8 bus_addr, u8 reg_addr, u8 *byte0, u8 *byte1);





#endif