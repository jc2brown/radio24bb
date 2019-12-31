
#include <stdlib.h>
#include "xgpiops.h"
#include "roe.h"
#include "scugic.h"
#include "gpiops.h"


XGpioPs *make_gpiops() {
	XGpioPs *gpiops = (XGpioPs *)malloc(sizeof(XGpioPs));
	return gpiops;
}




void gpiops_intr_handler(void *CallBackRef, u32 Bank, u32 Status) {
	print("INT!\n");


}




int init_gpiops(XGpioPs *gpiops, int device_id, XScuGic *scugic, int intr_id) {
	XGpioPs_Config *gpiops_config = XGpioPs_LookupConfig(device_id);
	_return_if_null_(gpiops_config);
	_return_if_error_(XGpioPs_CfgInitialize(gpiops, gpiops_config, gpiops_config->BaseAddr));


	XGpioPs_SetDirectionPin(gpiops, 54, 0x0);
	XGpioPs_SetDirectionPin(gpiops, 55, 0x0);

	XGpioPs_SetDirectionPin(gpiops, INTR_IN_PIN, 0x0); // input
	XGpioPs_SetIntrTypePin(gpiops, INTR_IN_PIN, XGPIOPS_IRQ_TYPE_EDGE_RISING);
	//XGpioPs_SetCallbackHandler(gpiops, (void *)gpiops, gpiops_intr_handler);
	XGpioPs_IntrEnablePin(gpiops, INTR_IN_PIN);

	return XST_SUCCESS;
}
