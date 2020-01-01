#include <stdlib.h>
#include "sleep.h"
#include "uartps.h"
#include "xuartps.h"
#include "roe.h"



static XUartPs *stdio_uartps; 

volatile int TotalReceivedCount;
volatile int TotalSentCount;
int TotalErrorCount;


static volatile int stdio_uartps_tx_pending = 0;
// static int stdio_uartps_rx_pending = 0;

void outbyte(char c) {
	stdio_uartps_tx_pending = 1;
	XUartPs_Send(stdio_uartps, &c, 1);
	while (stdio_uartps_tx_pending) { 
		usleep(10);
	}
}



XUartPs *make_uartps() {
	XUartPs *uartps = (XUartPs *)malloc(sizeof(XUartPs));
	return uartps;
}





volatile int TotalReceivedCount;
volatile int TotalSentCount;
int TotalErrorCount;


void uartps_handler(void *CallBackRef, u32 Event, unsigned int EventData)
{
	/* All of the data has been sent */
	if (Event == XUARTPS_EVENT_SENT_DATA) {
		stdio_uartps_tx_pending = 0;
		TotalSentCount = EventData;
	}

	/* All of the data has been received */
	if (Event == XUARTPS_EVENT_RECV_DATA) {
		TotalReceivedCount = EventData;
	}

	/*
	 * Data was received, but not the expected number of bytes, a
	 * timeout just indicates the data stopped for 8 character times
	 */
	if (Event == XUARTPS_EVENT_RECV_TOUT) {
		TotalReceivedCount = EventData;
	}

	/*
	 * Data was received with an error, keep the data but determine
	 * what kind of errors occurred
	 */
	if (Event == XUARTPS_EVENT_RECV_ERROR) {
		TotalReceivedCount = EventData;
		TotalErrorCount++;
	}

	/*
	 * Data was received with an parity or frame or break error, keep the data
	 * but determine what kind of errors occurred. Specific to Zynq Ultrascale+
	 * MP.
	 */
	if (Event == XUARTPS_EVENT_PARE_FRAME_BRKE) {
		TotalReceivedCount = EventData;
		TotalErrorCount++;
	}

	/*
	 * Data was received with an overrun error, keep the data but determine
	 * what kind of errors occurred. Specific to Zynq Ultrascale+ MP.
	 */
	if (Event == XUARTPS_EVENT_RECV_ORERR) {
		TotalReceivedCount = EventData;
		TotalErrorCount++;
	}
}





int init_uartps(XUartPs *uartps, XScuGic *scugic, int device_id, int intr_id) {
	XUartPs_Config *cfg = XUartPs_LookupConfig(device_id);
	_return_if_error_(XUartPs_CfgInitialize(uartps, cfg, cfg->BaseAddress));
	_return_if_error_(XUartPs_SelfTest(uartps));
	_return_if_error_(XScuGic_Connect(scugic, intr_id, (Xil_ExceptionHandler)XUartPs_InterruptHandler, (void *)uartps));
	XScuGic_Enable(scugic, intr_id);
	XUartPs_SetHandler(uartps, (XUartPs_Handler)uartps_handler, uartps);
	XUartPs_SetInterruptMask(uartps, 
			XUARTPS_IXR_TOUT | 
			XUARTPS_IXR_PARITY | 
			XUARTPS_IXR_FRAMING |
			XUARTPS_IXR_OVER | 
			XUARTPS_IXR_TXEMPTY | 
			XUARTPS_IXR_RXFULL |
			XUARTPS_IXR_RXOVR
	);
	XUartPs_SetRecvTimeout(uartps, 8);
	XUartPs_SetOperMode(uartps, XUARTPS_OPER_MODE_NORMAL);
	return XST_SUCCESS;
}

