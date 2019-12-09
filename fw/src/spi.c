#include "spi.h"
#include "xspips.h"
#include "roe.h"

XSpiPs xspips_inst;
XSpiPs *xspips_ptr = &xspips_inst;


int spi_init() {

	XSpiPs_Config *cfg = XSpiPs_LookupConfig(XPAR_PS7_SPI_1_DEVICE_ID);
	_return_if_error_(XSpiPs_CfgInitialize(xspips_ptr, cfg, cfg->BaseAddress));
	_return_if_error_(XSpiPs_SelfTest(xspips_ptr));
	//XSpiPs_Enable(xspips_ptr);

	XSpiPs_SetOptions(xspips_ptr,
			XSPIPS_MASTER_OPTION | XSPIPS_FORCE_SSELECT_OPTION | XSPIPS_CR_CPHA_MASK
	);

	XSpiPs_SetClkPrescaler(xspips_ptr, XSPIPS_CLK_PRESCALE_64);
	XSpiPs_SetSlaveSelect(xspips_ptr, 1);
	return XST_SUCCESS;

}
