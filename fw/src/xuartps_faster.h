#ifndef XUARTPS_FASTER_H
#define XUARTPS_FASTER_H

#define XUARTPS_MAX_BAUD_ERROR_RATE		 6U	/* max % error allowed */


extern XUartPs uart;

// Modified version of XUartPs_SetBaudRate()
// Original function prohibits baud rates above 921600
// This version removes XUARTPS_MAX_RATE assertation
//
s32 XUartPs_SetBaudRate_Faster(XUartPs *InstancePtr, u32 BaudRate);

#endif
