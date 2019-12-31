

#ifndef GPIOPS_H
#define GPIOPS_H

#include "xgpiops.h"

XGpioPs *make_gpiops();
int init_gpiops(XGpioPs *gpiops, int device_id, XScuGic *scugic, int intr_id);


#define INTR_IN_PIN 55


#endif