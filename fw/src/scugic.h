
#ifndef SCUGIC_H
#define SCUGIC_H

#include "xscugic.h"



#define INTC_DEVICE_INT_ID	XPAR_FABRIC_IRQ_F2P_01_INTR




XScuGic *make_scugic();
int init_scugic(XScuGic *scugic, int device_id);



#endif
