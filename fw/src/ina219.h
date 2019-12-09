#ifndef INA219_H
#define INA219_H




//#define INA219_ADDR 0x48




int ina219_config(void);




int ina219_read_vled_mv(int *vled_mv);
int ina219_read_iled_ma(int *iled_ma);
int ina219_read_pled_mw(int *pled_mw);

#endif
