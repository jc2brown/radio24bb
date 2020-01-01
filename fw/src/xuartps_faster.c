
#include "xuartps.h"
#include "xuartps_faster.h"




XUartPs uart;


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
