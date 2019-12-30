

#ifndef GPIOPS_H
#define GPIOPS_H

#include "xgpiops.h"

XGpioPs *make_gpiops();
int init_gpiops(XGpioPs *gpiops, int device_id);


#endif