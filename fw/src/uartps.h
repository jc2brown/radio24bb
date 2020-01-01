


#include "xuartps.h"
#include "xscugic.h"
#include "queue.h"

#ifndef UARTPS_H
#define UARTPS_H



extern void outbyte(char c);


struct uartps {
	XUartPs *xuartps;
	struct queue *rx_queue;
	struct queue *tx_queue;
	volatile int TotalReceivedCount;
	volatile int TotalSentCount;
	int TotalErrorCount;
	int rx_pending;
	int tx_pending;
	char tx_buf[4096];
	char rx_buf[2][4096];
	int rx_buf_ptr;
};


extern struct uartps *stdio_uart; 


struct uartps *make_uartps();
int init_uartps(struct uartps *uartps, XScuGic *scugic, int device_id, int intr_id);


#define XUARTPS_MAX_BAUD_ERROR_RATE		 6U	/* max % error allowed */

// Modified version of XUartPs_SetBaudRate()
// Original function prohibits baud rates above 921600
// This version removes XUARTPS_MAX_RATE assertation
//
s32 XUartPs_SetBaudRate_Faster(XUartPs *InstancePtr, u32 BaudRate);

#endif
