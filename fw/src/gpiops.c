
#include <stdlib.h>
#include "xgpiops.h"
#include "roe.h"


XGpioPs *make_gpiops() {
	XGpioPs *gpiops = (XGpioPs *)malloc(sizeof(XGpioPs));
	return gpiops;
}


int init_gpiops(XGpioPs *gpiops, int device_id) {
	XGpioPs_Config *gpiops_config = XGpioPs_LookupConfig(device_id);
	_return_if_null_(gpiops_config);
	_return_if_error_(XGpioPs_CfgInitialize(gpiops, gpiops_config, gpiops_config->BaseAddr));
	return XST_SUCCESS;
}
