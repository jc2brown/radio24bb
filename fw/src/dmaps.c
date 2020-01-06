
#include <stdlib.h>
#include "xdmaps.h"
#include "roe.h"
#include "scugic.h"
#include "xdmaps.h"
#include "dmaps.h"


XDmaPs *make_dmaps() {
	XDmaPs *dmaps = (XDmaPs *)malloc(sizeof(XDmaPs));
	return dmaps;
}





int init_dmaps(
		XDmaPs *dmaps, 
		XScuGic *scugic, 
		int device_id, 
		int fault_intr_id, 
		int ch0_done_intr_idm, 
		void ch0_done_handler(unsigned int, XDmaPs_Cmd *, void *),
		void *ch0_callback_arg
) {

	XDmaPs_Config *dmaps_config = XDmaPs_LookupConfig(device_id);
	_return_if_null_(dmaps_config);
	_return_if_error_(XDmaPs_CfgInitialize(dmaps, dmaps_config, dmaps_config->BaseAddr));

	Status = XScuGic_Connect(scugic, fault_intr_id, (Xil_InterruptHandler)XDmaPs_FaultISR, (void *)dmaps);
	XScuGic_Enable(GicPtr, DMA_FAULT_INTR);

	Status = XScuGic_Connect(scugic, ch0_done_intr_id, (Xil_InterruptHandler)XDmaPs_DoneISR_0, (void *)dmaps);
	XScuGic_Enable(GicPtr, DMA_DONE_INTR_0);

	XDmaPs_SetDoneHandler(dmaps, 0, ch0_done_handler, ch0_callback_arg);


	return XST_SUCCESS;
}

