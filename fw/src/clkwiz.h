
#include "xclk_wiz.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xscugic.h"
#include "xil_printf.h"
#include "sleep.h"
#include "ClkWiz.h"


#define TCXO_19M2_FREQ ((double)19.2e6)
#define TCXO_96M_FREQ ((double)96e6)
#define PL_CLK0_FREQ  (XPAR_PSU_CORTEXA53_0_TIMESTAMP_CLK_FREQ / 1000) 


int Wait_For_Lock(XClk_Wiz *clkwiz);
int ConfigClkWizQuadrature(XClk_Wiz *clkwiz, u32 vco_khz, u32 clkout_khz);
u32 init_clkwiz(XClk_Wiz *clkwiz, u32 device_id);


