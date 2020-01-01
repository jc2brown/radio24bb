#include <stdlib.h>
#include "xpseudo_asm.h"
#include "sleep.h"
#include "uartps.h"
#include "xuartps.h"
#include "roe.h"
#include "queue.h"


struct uartps *stdio_uart = NULL; 


static volatile int stdio_uart_tx_pending = 0;
// static int stdio_uart_rx_pending = 0;



void uart_send(struct uartps *uart) {
	
	static char _c;	

	int ireg = mfcpsr();
	Xil_ExceptionDisable();


	if (uart->tx_pending) {
		return;
	}

	if (uart->tx_queue->size == 0) {
		return;
	}

/*
	// What if tx_pending is stuck high?
	for (int i = 0; i < 10000; ++i) {
		if (!uart->tx_pending) { 
			break;
		}
		usleep(10);
	}
	*/

	int i;
	queue_get(uart->tx_queue, (void **)&i);
	stdio_uart->tx_pending = 1;
	// XUartPs_Send(uart->xuartps, (void *)&c, 1);
	_c = (char)i;

	//usleep(1000);


	XUartPs_Send(uart->xuartps, &_c, 1);


	// Xil_ExceptionEnable();
	mtcpsr(ireg);


}




	static char _rx;

void uart_recv(struct uartps *uart) {
	

	int ireg = mfcpsr();
	Xil_ExceptionDisable();


	if (uart->rx_pending) {
		return;
	}

	if (uart->rx_queue->size == uart->rx_queue->size == uart->rx_queue->capacity) {
		return;
	}


	int i;
	// XUartPs_Send(uart->xuartps, (void *)&c, 1);

	//usleep(1000);


	uart->rx_pending = 1;
	XUartPs_Recv(uart->xuartps, uart->rx_buf[uart->rx_buf_ptr], 4096);



	// Xil_ExceptionEnable();
	mtcpsr(ireg);


}









void outbyte(char c) {
	if (stdio_uart == NULL) {
		XUartPs_SendByte(STDOUT_BASEADDRESS, c);
		return;
	}
	else {

		int i = (int)c;

		int ireg = mfcpsr();
		 Xil_ExceptionDisable();

		queue_put(stdio_uart->tx_queue, (void *)i);
		uart_send(stdio_uart);

		//Xil_ExceptionEnable();

		mtcpsr(ireg);

	}
}



struct uartps *make_uartps() {

	struct uartps *uart = (struct uartps *)malloc(sizeof(struct uartps));
	if (uart == NULL) return NULL;

	uart->xuartps = (XUartPs *)malloc(sizeof(XUartPs));
	if (uart->xuartps == NULL) return NULL;

	uart->rx_queue = make_queue(256, 1024*1024);
	if (uart->rx_queue == NULL) return NULL;

	uart->tx_queue = make_queue(256, 1024*1024);	
	if (uart->tx_queue == NULL) return NULL;

	return uart;
}





/*
int uart_tx(char c) {

}
*/ 


void uart_handler(void *arg, u32 Event, unsigned int EventData) {

	struct uartps *uart = (struct uartps *)arg;

	/* All of the data has been sent */
	if (Event == XUARTPS_EVENT_SENT_DATA) {
		uart->tx_pending = 0;
		uart->TotalSentCount = EventData;

		uart_send(uart);
/*
		if (uart->tx_queue->size != 0) {
			char c;
			queue_get(uart->tx_queue, (void **)&c);
			outbyte(c);
		}
		*/
	}

	/* All of the data has been received */
	if (Event == XUARTPS_EVENT_RECV_DATA) {

		/*
		uart->TotalReceivedCount = EventData;

		queue_put(uart->rx_queue, (void *)(int)_rx);

*/



		uart->TotalReceivedCount = EventData;

		int ptr = uart->rx_buf_ptr;
		uart->rx_buf_ptr = (uart->rx_buf_ptr + 1) % 2;
		uart->rx_pending = 0;
		uart_recv(uart);

		for (int i = 0; i < EventData; ++i) {
			char c = uart->rx_buf[ptr][i];
			queue_put(uart->rx_queue, (void *)(int)c);
		}



	}

	/*
	 * Data was received, but not the expected number of bytes, a
	 * timeout just indicates the data stopped for 8 character times
	 */
	if (Event == XUARTPS_EVENT_RECV_TOUT) {

		uart->TotalReceivedCount = EventData;

		int ptr = uart->rx_buf_ptr;
		uart->rx_buf_ptr = (uart->rx_buf_ptr + 1) % 2;
		uart->rx_pending = 0;
		uart_recv(uart);

		for (int i = 0; i < EventData; ++i) {
			char c = uart->rx_buf[ptr][i];
			queue_put(uart->rx_queue, (void *)(int)c);
		}

	}

	/*
	 * Data was received with an error, keep the data but determine
	 * what kind of errors occurred
	 */
	if (Event == XUARTPS_EVENT_RECV_ERROR) {
		uart->TotalReceivedCount = EventData;
		uart->TotalErrorCount++;
	}

	/*
	 * Data was received with an parity or frame or break error, keep the data
	 * but determine what kind of errors occurred. Specific to Zynq Ultrascale+
	 * MP.
	 */
	if (Event == XUARTPS_EVENT_PARE_FRAME_BRKE) {
		uart->TotalReceivedCount = EventData;
		uart->TotalErrorCount++;
	}

	/*
	 * Data was received with an overrun error, keep the data but determine
	 * what kind of errors occurred. Specific to Zynq Ultrascale+ MP.
	 */
	if (Event == XUARTPS_EVENT_RECV_ORERR) {
		uart->TotalReceivedCount = EventData;
		uart->TotalErrorCount++;
	}
}





int init_uartps(struct uartps *uart, XScuGic *scugic, int device_id, int intr_id) {
	uart->TotalReceivedCount = 0;
	uart->TotalSentCount = 0;
	uart->TotalErrorCount = 0;
	uart->rx_pending = 0;
	uart->tx_pending = 0;
	uart->rx_buf_ptr = 0;

	XUartPs_Config *cfg = XUartPs_LookupConfig(device_id);
	_return_if_error_(XUartPs_CfgInitialize(uart->xuartps, cfg, cfg->BaseAddress));
	_return_if_error_(XUartPs_SelfTest(uart->xuartps));
	XUartPs_SetOptions(uart->xuartps, XUartPs_GetOptions(uart->xuartps)|XUARTPS_OPTION_RESET_RX);
	_return_if_error_(XUartPs_SetBaudRate_Faster(uart->xuartps, 115200));
	_return_if_error_(XScuGic_Connect(scugic, intr_id, (Xil_ExceptionHandler)XUartPs_InterruptHandler, (void *)uart->xuartps));
	XScuGic_Enable(scugic, intr_id);
	XUartPs_SetHandler(uart->xuartps, (XUartPs_Handler)uart_handler, (void *)uart);
	XUartPs_SetInterruptMask(uart->xuartps, 
			XUARTPS_IXR_TOUT | 
			XUARTPS_IXR_PARITY | 
			XUARTPS_IXR_FRAMING |
			XUARTPS_IXR_OVER | 
			XUARTPS_IXR_TXEMPTY | 
			XUARTPS_IXR_RXFULL |
			XUARTPS_IXR_RXOVR
	);
	XUartPs_SetRecvTimeout(uart->xuartps, 8);
	XUartPs_SetOperMode(uart->xuartps, XUARTPS_OPER_MODE_NORMAL);

	return XST_SUCCESS;
}




// Modified version of XUartPs_SetBaudRate()
// Original function prohibits baud rates above 921600
// This version removes XUARTPS_MAX_RATE assertation
//
s32 XUartPs_SetBaudRate_Faster(XUartPs *InstancePtr, u32 BaudRate)
{
	u32 IterBAUDDIV;	/* Iterator for available baud divisor values */
	u32 BRGR_Value;		/* Calculated value for baud rate generator */
	u32 CalcBaudRate;	/* Calculated baud rate */
	u32 BaudError;		/* Diff between calculated and requested baud rate */
	u32 Best_BRGR = 0U;	/* Best value for baud rate generator */
	u8 Best_BAUDDIV = 0U;	/* Best value for baud divisor */
	u32 Best_Error = 0xFFFFFFFFU;
	u32 PercentError;
	u32 ModeReg;
	u32 InputClk;

	/* Asserts validate the input arguments */
	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	//Xil_AssertNonvoid(BaudRate <= (u32)XUARTPS_MAX_RATE);
	Xil_AssertNonvoid(BaudRate >= (u32)XUARTPS_MIN_RATE);

	/*
	 * Make sure the baud rate is not impossilby large.
	 * Fastest possible baud rate is Input Clock / 2.
	 */
	if ((BaudRate * 2) > InstancePtr->Config.InputClockHz) {
		return XST_UART_BAUD_ERROR;
	}
	/* Check whether the input clock is divided by 8 */
	ModeReg = XUartPs_ReadReg( InstancePtr->Config.BaseAddress, XUARTPS_MR_OFFSET);

	InputClk = InstancePtr->Config.InputClockHz;
	if(ModeReg & XUARTPS_MR_CLKSEL) {
		InputClk = InstancePtr->Config.InputClockHz / 8;
	}

	/*
	 * Determine the Baud divider. It can be 4to 254.
	 * Loop through all possible combinations
	 */
	for (IterBAUDDIV = 4; IterBAUDDIV < 255; IterBAUDDIV++) {

		/* Calculate the value for BRGR register */
		BRGR_Value = InputClk / (BaudRate * (IterBAUDDIV + 1));

		/* Calculate the baud rate from the BRGR value */
		CalcBaudRate = InputClk/ (BRGR_Value * (IterBAUDDIV + 1));

		/* Avoid unsigned integer underflow */
		if (BaudRate > CalcBaudRate) {
			BaudError = BaudRate - CalcBaudRate;
		}
		else {
			BaudError = CalcBaudRate - BaudRate;
		}

		/* Find the calculated baud rate closest to requested baud rate. */
		if (Best_Error > BaudError) {

			Best_BRGR = BRGR_Value;
			Best_BAUDDIV = IterBAUDDIV;
			Best_Error = BaudError;
		}
	}

	/* Make sure the best error is not too large. */
	PercentError = (Best_Error * 100) / BaudRate;
	if (XUARTPS_MAX_BAUD_ERROR_RATE < PercentError) {
		return XST_UART_BAUD_ERROR;
	}

	/* Disable TX and RX to avoid glitches when setting the baud rate. */
	XUartPs_DisableUart(InstancePtr);

	XUartPs_WriteReg(InstancePtr->Config.BaseAddress, XUARTPS_BAUDGEN_OFFSET, Best_BRGR);
	XUartPs_WriteReg(InstancePtr->Config.BaseAddress, XUARTPS_BAUDDIV_OFFSET, Best_BAUDDIV);

	/* RX and TX SW reset */
	XUartPs_WriteReg(InstancePtr->Config.BaseAddress, XUARTPS_CR_OFFSET, XUARTPS_CR_TXRST | XUARTPS_CR_RXRST);

	/* Enable device */
	XUartPs_EnableUart(InstancePtr);

	InstancePtr->BaudRate = BaudRate;

	return XST_SUCCESS;

}


