
#include <stdlib.h>
#include "xgpiops.h"
#include "roe.h"
#include "scugic.h"
#include "gpiops.h"


XGpioPs *make_gpiops() {
	XGpioPs *gpiops = (XGpioPs *)malloc(sizeof(XGpioPs));
	return gpiops;
}



#define GPIO_PIN_DIR_IN 0
#define GPIO_PIN_DIR_OUT 1
#define GPIO_PIN_OUT_EN 1


// Set the specified pin as an output and write the given value
void gpiops_write_output_pin(XGpioPs *gpiops, int pin, int value) {
    XGpioPs_SetDirectionPin(gpiops, pin, GPIO_PIN_DIR_OUT);
    XGpioPs_SetOutputEnablePin(gpiops, pin, GPIO_PIN_OUT_EN);
	XGpioPs_WritePin(gpiops, pin, value);
}



int gpiops_read_input_pin(XGpioPs *gpiops, int pin) {
    XGpioPs_SetDirectionPin(gpiops, pin, GPIO_PIN_DIR_IN);
    XGpioPs_SetOutputEnablePin(gpiops, pin, !GPIO_PIN_OUT_EN);
	return XGpioPs_ReadPin(gpiops, pin);
}





/*
void gpiops_intr_handler(void *CallBackRef, u32 Bank, u32 Status) {
	print("INT!\n");


}
*/



int init_gpiops(XGpioPs *gpiops, int device_id, XScuGic *scugic, int intr_id) {
	XGpioPs_Config *gpiops_config = XGpioPs_LookupConfig(device_id);
	_return_if_null_(gpiops_config);
	_return_if_error_(XGpioPs_CfgInitialize(gpiops, gpiops_config, gpiops_config->BaseAddr));


	// XGpioPs_SetDirectionPin(gpiops, 54, 0x0);
	// XGpioPs_SetDirectionPin(gpiops, 55, 0x0);

	// XGpioPs_SetDirectionPin(gpiops, INTR_IN_PIN, 0x0); // input
	// XGpioPs_SetIntrTypePin(gpiops, INTR_IN_PIN, XGPIOPS_IRQ_TYPE_EDGE_RISING);
	//XGpioPs_SetCallbackHandler(gpiops, (void *)gpiops, gpiops_intr_handler);
	// XGpioPs_IntrEnablePin(gpiops, INTR_IN_PIN);

	return XST_SUCCESS;
}
