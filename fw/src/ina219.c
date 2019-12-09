#include <stdint.h>

#include "roe.h"

#include "i2c.h"
#include "ina219.h"



#define INA219_MASK_ENABLE_REG_ADDR 0x06

#define INA219_MASK_ENABLE_REG_CNVR_FLAG (1<<10)
#define INA219_MASK_ENABLE_REG_APOL_FLAG (1<<1)
#define INA219_MASK_ENABLE_REG_LEN_FLAG (1<<0)




#define INA219_CONFIG_REG_ADDR 0
#define INA219_SHUNT_REG_ADDR 1
#define INA219_BUS_REG_ADDR 2
#define INA219_POWER_REG_ADDR 3
#define INA219_CURRENT_REG_ADDR 4
#define INA219_CAL_REG_ADDR 5




#define I2C_INA219_ADDR 0x40
/*
static int ina219_set_reg_pointer(int reg) {
	return_if_error(i2c_write(I2C_INA219_ADDR, (u8*)&reg, 1));
	return XST_SUCCESS;
}
*/

static int ina219_write_word(int reg, int word) {
	u8 buf[3] = {
			reg & 0xFF,
			(word >> 8) & 0xFF,
			word & 0xFF
	};
	_return_if_error_(i2c_write(I2C_INA219_ADDR, buf, 3));
	return XST_SUCCESS;
}

static int ina219_read_word(int reg, int *word) {
	u8 buf[2];


	//return_if_error(i2c_read(I2C_INA219_ADDR, buf, 2))
	_return_if_error_(i2c_read8(I2C_INA219_ADDR, reg, buf, 2))


	*word = (buf[0] << 8) | buf[1];
	return XST_SUCCESS;
}



static int ina219_write_reg(int reg, int value) {
	_return_if_error_(ina219_write_word(reg, value));
	return XST_SUCCESS;

}


static int ina219_read_reg(int reg, int *value) {
	//return_if_error(ina219_set_reg_pointer(reg));
	_return_if_error_(ina219_read_word(reg, value));
	return XST_SUCCESS;
}






static int ina219_write_config(int RST, int BRNG, int PG, int BADC, int SADC, int MODE) {
	u16 config =
			((RST & 0b1) << 15) |
			((BRNG & 0b1) << 13) |
			((PG & 0b11) << 11) |
			((BADC & 0b1111) << 7) |
			((SADC & 0b1111) << 3) |
			((MODE & 0b111) << 0);
	_return_if_error_(ina219_write_reg(INA219_BUS_REG_ADDR, config));




	return XST_SUCCESS;
}


#define INA219_IMAX 4000 //mA
#define INA219_R_SHUNT 100 //mohm

#define INA219_CAL 1664 // determined experimentally

static int ina219_write_calibration() {
	int cal = INA219_CAL;
	_return_if_error_(ina219_write_reg(INA219_CAL_REG_ADDR, cal));
	return XST_SUCCESS;
}



int ina219_config() {
/*
	uint8_t buf[3];

	buf[0] = INA219_MASK_ENABLE_REG_ADDR;
	_return_if_error_(XIicPs_MasterSendPolled(get_xiicps(), buf, 1, INA219_ADDR), "&WrBuf=%p, ByteCount=%d, SlvAddr=0x%X\n", &buf, 1, INA219_ADDR);
	_return_if_error_(XIicPs_MasterRecvPolled(get_xiicps(), buf, 2, INA219_ADDR), "&WrBuf=%p, ByteCount=%d, SlvAddr=0x%X\n", &buf, 1, INA219_ADDR);
	_return_if_error_(i2c_wait_for_bus(I2C_TIMEOUT));


	buf[0] = INA219_MASK_ENABLE_REG_ADDR;
	buf[1] = INA219_MASK_ENABLE_REG_CNVR_FLAG >> 8;
	buf[2] = INA219_MASK_ENABLE_REG_APOL_FLAG | INA219_MASK_ENABLE_REG_LEN_FLAG;
	_return_if_error_(XIicPs_MasterSendPolled(get_xiicps(), buf, 3, INA219_ADDR), "&WrBuf=%p, ByteCount=%d, SlvAddr=0x%X\n", &buf, 3, INA219_ADDR);
	_return_if_error_(i2c_wait_for_bus(I2C_TIMEOUT));
*/

	_return_if_error_(ina219_write_config(0, 0, 0b00, 0b0011, 0b0011, 0b110));
	//_return_if_error_(ina219_write_config(0, 0, 0b00, 0b0011, 0b1011, 0b110)); // Increase number of shunt averages



	_return_if_error_(ina219_write_calibration());


	return XST_SUCCESS;
}



int ina219_read_vled_mv(int *vled_mv) {
	int value;
	_return_if_error_(ina219_read_reg(INA219_BUS_REG_ADDR, &value));
	//*vled_mv = (value >> 3) * 10;
	*vled_mv = (value >> 1);
	return XST_SUCCESS;
}


#define INA219_CURRENT_OFFSET_ERROR_MA 3
#define INA219_CURRENT_ZERO_TOLERANCE 2


int ina219_read_iled_ma(int *iled_ma) {
	int value;
	_return_if_error_(ina219_read_reg(INA219_CURRENT_REG_ADDR, &value));
	value = value >> 2;
	value -= INA219_CURRENT_OFFSET_ERROR_MA;
	*iled_ma = (value > INA219_CURRENT_ZERO_TOLERANCE ? value : 0 );
	return XST_SUCCESS;
}


#define INA219_POWER_OFFSET_ERROR_MW 12
#define INA219_POWER_ZERO_TOLERANCE 5


int ina219_read_pled_mw(int *pled_mw) {
	int value;
	_return_if_error_(ina219_read_reg(INA219_POWER_REG_ADDR, &value));
	value *= 5;//(value * 100) >> 4;
	//value -= INA219_POWER_OFFSET_ERROR_MW;
	*pled_mw = (value > INA219_POWER_ZERO_TOLERANCE ? value : 0 );
	return XST_SUCCESS;

}
