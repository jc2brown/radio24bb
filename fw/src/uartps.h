


#include "xuartps.h"
#include "xscugic.h"

#ifndef UARTPS_H
#define UARTPS_H

extern void outbyte(char c);

XUartPs *make_uartps();
int init_uartps(XUartPs *uartps, XScuGic *scugic, int device_id, int intr_id);


#endif
