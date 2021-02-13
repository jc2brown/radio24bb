

#ifndef GPIOPS_H
#define GPIOPS_H

#include "xscugic.h"
#include "xgpiops.h"

XGpioPs *make_gpiops();
int init_gpiops(XGpioPs *gpiops, int device_id, XScuGic *scugic, int intr_id);


void gpiops_write_output_pin(XGpioPs *gpiops, int pin, int value);
int gpiops_read_input_pin(XGpioPs *gpiops, int pin);



#define INTR_IN_PIN 55


#endif