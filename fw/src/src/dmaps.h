

#ifndef DMAPS_H
#define DMAPS_H

#include "xdmaps.h"



XDmaPs *make_dmaps();


int init_dmaps(
		XDmaPs *dmaps, 
		XScuGic *scugic, 
		int device_id, 
		int fault_intr_id, 
		int ch0_done_intr_id, 
		void ch0_done_handler(unsigned int, XDmaPs_Cmd *, void *),
		void *ch0_callback_arg
);



#endif