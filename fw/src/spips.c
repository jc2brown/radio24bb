#include <stdlib.h>

#include "spips.h"
#include "xspips.h"
#include "roe.h"



XSpiPs *make_spips() {
	XSpiPs *spips = (XSpiPs *)malloc(sizeof(XSpiPs));
	return spips;
}


int init_spips(XSpiPs *spips, int device_id) {
	XSpiPs_Config *cfg = XSpiPs_LookupConfig(device_id);
	_return_if_error_(XSpiPs_CfgInitialize(spips, cfg, cfg->BaseAddress));
	_return_if_error_(XSpiPs_SelfTest(spips));
	XSpiPs_SetOptions(spips, XSPIPS_MASTER_OPTION | XSPIPS_FORCE_SSELECT_OPTION | XSPIPS_CR_CPHA_MASK);
	XSpiPs_SetClkPrescaler(spips, XSPIPS_CLK_PRESCALE_64);
	XSpiPs_SetSlaveSelect(spips, 0x7);
	return XST_SUCCESS;
}

