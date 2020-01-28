
#include <stdlib.h>

#include "roe.h"
#include "clock_reset.h"
#include "sleep.h"
#include "xgpiops.h"
#include "gpiops.h"
#include "clkwiz.h"


#define GPIOPS_BASE_PIN 54

#define SYS_RESET_PIN (GPIOPS_BASE_PIN+0)

#define TCXO_96M_RESET_PIN (GPIOPS_BASE_PIN+2)
#define TCXO_96M_LOCKED_PIN (GPIOPS_BASE_PIN+3)

#define CLK_CLKWIZ_GPIOPS_BASE_PIN (GPIOPS_BASE_PIN+4)
#define CLK_CLKIN_SEL_PIN (GPIOPS_BASE_PIN+5)


#define MCLK_CLKWIZ_GPIOPS_BASE_PIN (GPIOPS_BASE_PIN+34)
#define MCLK_CLKIN_SEL_PIN (GPIOPS_BASE_PIN+35)




#define CLK_CLKIN_PL_CLK0 0
#define CLK_CLKIN_TCXO_96M 1

#define MCLK_CLKIN_PL_CLK0 0
#define MCLK_CLKIN_TCXO_96M 1

#define PL_CLK0_FREQ_HZ ((uint64_t)(100000000ULL))
#define TCXO_96M_FREQ_HZ ((uint64_t)(96000000ULL))



// Frequency of the fmeas reference clock (currently pl_clk0)
#define REF_CLK_FREQ ((double)(100e6))

// Reference counter upper limit - constant value set in RTL
#define REF_COUNT    ((double)(10e6))

// Time in seconds required to complete frequency measurement, plus 20%
#define FMEAS_WAIT   (((double)(1.2)) * (REF_COUNT) / (REF_CLK_FREQ)) 




// These are the signatures of clock-specific functions which will be passed to the generic routines in the module.
typedef void (*SetReset_fcn)(XGpioPs *, int pin, int value);
typedef void (*IsLocked_fcn)(XGpioPs *, int pin);
typedef void (*FMeasEnable_fcn)(XGpioPs *, int pin);
typedef void (*FMeasCount_fcn)(XGpioPs *, int msb_pin);






void set_sys_reset(struct clock_reset *clkrst, int reset) {
	gpiops_write_output_pin(clkrst->gpiops, SYS_RESET_PIN, reset);
}



void set_tcxo_96m_reset(struct clock_reset *clkrst, int reset) {
	gpiops_write_output_pin(clkrst->gpiops, TCXO_96M_RESET_PIN, reset);
}

int is_tcxo_96m_locked(struct clock_reset *clkrst) {
	return gpiops_read_input_pin(clkrst->gpiops, TCXO_96M_RESET_PIN);
}





/*
double measure_frequency(XGpioPs *gpiops, FMeasEnable_fcn, FMeasCount_fcn) {

	// Deassert fmeas_enable pin
	FMeasEnable_fcn(gpiops, 0);

	// Assert fmeas_enable pin to begin measurement
	FMeasEnable_fcn(gpiops, 0);

	usleep(120000); // Wait 120ms for measurement to complete



	int count = FMeasCount_fcn(gpiops);

	double freq = (double)count * REF_CLK_FREQ / REF_COUNT;
	return freq;

}

*/




// This routine implements a procedure which activates a clock generator (i.e. MMCM/PLL/ClkWiz) in a controlled fashion.
// Callers must supply:
//		a function `set_clkin_sel` which drives an XGpioPs pin connected to the clkin_sel pin of the clock generator 
//		a function `is_locked` which reads an XGpioPs pin connected to the locked pin of the clock generator 
// This function waits up to 100 milliseconds for the clock generator to lock.
//   - If lock is achieved at any point within the waiting period, the function exits the wait loop immediately.
//   - Otherwise, a fatal error message is printed at the end of the waiting period and the function will hang forever.
// If the clock becomes locked, this function will measure and print its frequency unless the FMeas functions are NULL.



void enable_tcxo_96m(
	struct clock_reset *clkrst
	/*
	XGpioPs *gpiops, 
	char *clk_name
	SetClkinSel_fcn set_clkin_sel, 
	IsLocked_fcn is_locked, 
	FMeasEnable_fcn fmeas_enable, 
	FMeasCount_fcn fmeas_count
	*/
) {

	// Entry message
	xil_printf("Bringing up TCXO_96M\n");

	// Deassert PLL/MMCM/ClkWiz reset
	gpiops_write_output_pin(clkrst->gpiops, TCXO_96M_RESET_PIN, 0);

	// Poll locked pin once per millisecond for 1000 milliseconds or until the locked pin goes high
	int locked = 0;
	for (int i = 0; i < 1000; ++i) {
		if (gpiops_read_input_pin(clkrst->gpiops, TCXO_96M_LOCKED_PIN)) {
			locked = 1;
			break;
		} else {
			usleep(1000);
		}
	}

	// If the locked pin stayed low, print an error message and hang here forever 
	if (!locked) {
		xil_printf("FATAL: TCXO_96M failed to lock after 1000ms\n");
		while(1);
	}	

	else {
		// Successful exit message
		xil_printf("SUCCESS: TCXO_96M is locked\n");
	}
}





struct clock_reset *make_clock_reset() {
	struct clock_reset *clkrst = (struct clock_reset *)malloc(sizeof(struct clock_reset));
	if (clkrst == NULL) return NULL;

	clkrst->clk_clkwiz = make_clkwiz();
	if (clkrst->clk_clkwiz == NULL) return NULL;

	clkrst->mclk_clkwiz = make_clkwiz();
	if (clkrst->mclk_clkwiz == NULL) return NULL;

	return clkrst;
}








/*
void clkrst_down(struct clock_reset *clkrst) {

    //
    // Reset network
    //
	set_tcxo_96m_reset(clkrst->gpiops, 1);
	set_clk_reset(clkrst->gpiops, 1);
	set_mclk_reset(clkrst->gpiops, 1);
	set_sys_reset(clkrst->gpiops, 1);
}


*/



void set_clk_frequency(struct clock_reset *clkrst, int clkin_sel, uint64_t target_clkout_hz) { 
	clkwiz_set_frequency(clkrst->clk_clkwiz, clkin_sel, target_clkout_hz);
}


void set_mclk_frequency(struct clock_reset *clkrst, int clkin_sel, uint64_t target_clkout_hz) { 
	clkwiz_set_frequency(clkrst->mclk_clkwiz, clkin_sel, target_clkout_hz);
}




int init_clock_reset(struct clock_reset *clkrst, XGpioPs *gpiops) {

	clkrst_trace("Enter %s\n", __func__);

	clkrst->gpiops = gpiops;


	_return_if_error_(
		init_clkwiz(
			clkrst->clk_clkwiz, 
			clkrst->gpiops, 
			XPAR_CLK_CLKWIZ_DEVICE_ID, 
			PL_CLK0_FREQ_HZ, 
			TCXO_96M_FREQ_HZ,
			CLK_CLKIN_SEL_PIN
	));


/*
	_return_if_error_(
		init_clkwiz(
			clkrst->mclk_clkwiz, 
			clkrst->gpiops, 
			XPAR_MCLK_CLKWIZ_DEVICE_ID, 
			PL_CLK0_FREQ_HZ, 
			TCXO_96M_FREQ_HZ,
			MCLK_CLKIN_SEL_PIN
	));
*/

    //
    // Bring up 19.2MHz -> 96MHz PLL
    //
	// enable_tcxo_96m(clkrst);
    //
    // Bring up clk ClkWiz
    //
	set_clk_frequency(clkrst, CLK_CLKIN_PL_CLK0, 100e6);
    //
    // Bring up mclk ClkWiz
    //
	// set_mclk_frequency(clkrst, MCLK_CLKIN_TCXO_96M, 9.728e6);	
	//set_mclk_frequency(clkrst, CLK_CLKIN_PL_CLK0, 9.728e6);	
    //
    // Enable system
    //
	set_sys_reset(clkrst, 0);



	clkrst_trace("Exit %s\n", __func__);
	return XST_SUCCESS;
}

