#include <stdlib.h>
#include "scugic.h"
#include "roe.h"



int SetUpInterruptSystem(XScuGic *XScuGicInstancePtr) {
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler,	XScuGicInstancePtr);
	return XST_SUCCESS;
}



XScuGic *make_scugic() {
	XScuGic *scugic = (XScuGic *)malloc(sizeof(XScuGic));
	return scugic;
}



int init_scugic(XScuGic *scugic, int device_id) {
	XScuGic_Config *scugic_cfg = XScuGic_LookupConfig(device_id);
	_return_if_null_(scugic_cfg);
	_return_if_error_(XScuGic_CfgInitialize(scugic, scugic_cfg, scugic_cfg->CpuBaseAddress));
	_return_if_error_(XScuGic_SelfTest(scugic));
	_return_if_error_(SetUpInterruptSystem(scugic));
	//Xil_ExceptionEnableMask(XIL_EXCEPTION_IRQ);
	//Xil_ExceptionEnable();
	return XST_SUCCESS;
}


