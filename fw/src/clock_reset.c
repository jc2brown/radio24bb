


#include "clock_reset.h"
#include "sleep.h"
#include "xgpiops.h"



#define GPIO_PIN_DIR_OUT 1
#define GPIO_PIN_DIR_OUT_EN 1

#define SYS_RESET_PIN ??

#define TCXO_96M_RESET_PIN ??
#define TCXO_96M_LOCKED_PIN ??

#define CLK_RESET_PIN ??
#define CLK_LOCKED_PIN ??

#define MCLK_RESET_PIN ??
#define MCLK_LOCKED_PIN ??




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




// Set the specified pin as an output and write the given value
void gpiops_write_output_pin(XGpioPs *gpiops, int pin, int value) {
    XGpioPs_SetDirectionPin(gpiops, pin, GPIO_PIN_DIR_OUT);
    XGpioPs_SetOutputEnablePin(gpiops, pin, GPIO_PIN_DIR_OUT_EN);
	XGpioPs_WritePin(gpiops, pin, value);
}



int gpiops_read_input_pin(XGpioPs *gpiops, int pin) {
    XGpioPs_SetDirectionPin(gpiops, pin, GPIO_PIN_DIR_IN);
    XGpioPs_SetOutputEnablePin(gpiops, pin, !GPIO_PIN_DIR_OUT_EN);
	return XGpioPs_ReadPin(gpiops, pin);
}




void set_sys_reset(XGpioPs *gpiops, int reset) {
	gpiops_write_output_pin(gpiops, SYS_RESET_PIN, reset);
}



void set_tcxo_96m_reset(XGpioPs *gpiops, int reset) {
	gpiops_write_output_pin(gpiops, TCXO_96M_RESET_PIN, reset);
}

int is_tcxo_96m_locked(XGpioPs *gpiops) {
	return gpiops_read_input_pin(gpiops, TCXO_96M_RESET_PIN, reset);
}



void set_clk_reset(XGpioPs *gpiops, int reset) {
	gpiops_write_output_pin(gpiops, CLK_RESET_PIN, reset);
}

int is_clk_locked(XGpioPs *gpiops) {
	return gpiops_read_input_pin(gpiops, CLK_LOCKED_PIN);
}



void set_mclk_reset(XGpioPs *gpiops, int reset) {
	gpiops_write_output_pin(gpiops, MCLK_RESET_PIN, reset);
}

int is_mclk_locked(XGpioPs *gpiops) {
	return gpiops_read_input_pin(gpiops, MCLK_LOCKED_PIN);
}



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






// This routine implements a procedure which activates a clock generator (i.e. MMCM/PLL/ClkWiz) in a controlled fashion.
// Callers must supply:
//		a function `set_reset` which drives a GpioPs pin connected to the reset pin of the clock generator 
//		a function `is_locked` which reads a GpioPs pin connected to the locked pin of the clock generator 
// This function waits up to 100 milliseconds for the clock generator to lock.
//   - If lock is achieved at any point within the waiting period, the function exits the wait loop immediately.
//   - Otherwise, a fatal error message is printed at the end of the waiting period and the function will hang forever.
// If the clock becomes locked, this function will measure and print its frequency unless the FMeas functions are NULL.
void bring_up_clock(
	XGpioPs *gpiops, 
	char *clk_name, 
	SetReset_fcn set_reset, 
	IsLocked_fcn is_locked, 
	FMeasEnable_fcn fmeas_enable, 
	FMeasCount_fcn fmeas_count
) {

	// Entry message
	xil_printf("Bringing up clock: %s...\n", clk_name);

	// Deassert PLL/MMCM/ClkWiz reset
	set_reset(gpiops, 0);

	// Poll locked pin once per millisecond for 100 milliseconds or until the locked pin goes high
	int locked = 0;
	for (int i = 0; i < 100; ++i) {
		if (is_locked(gpiops)) {
			locked = 1;
			break;
		} else {
			usleep(1000);
		}
	}

	// If the locked pin stayed low, print an error message and hang here forever 
	if (!locked) {
		xil_printf("FATAL: TCXO_96M failed to lock after 100ms\n");
		while(1);
	}

	// Successful exit message
	xil_printf("SUCCESS: %s is locked\n", clk_name);

	if (fmeas_enable != NULL && fmeas_count != NULL) {
		double measure_frequency(gpiops, fmeas_enable, fmeas_count);
	}
	// TODO: measure frequency here? Probably not... n.b. TCXO_96M has no freq_meas block
}









void init_clock_reset() {

	XGpioPs gpiops_inst;
	XGpioPs *gpiops = &gpiops_inst;

	XGpioPs_Config *gpiops_cfg = XGpioPs_LookupConfig();


    //
    // Reset network
    //
	set_tcxo_96m_reset(gpiops, 1);
	set_clk_reset(gpiops, 1);
	set_mclk_reset(gpiops, 1);
	set_sys_reset(gpiops, 1);

    
    //
    // Bring up 19.2MHz -> 96MHz PLL
    //
	bring_up_clock(gpiops, "TCXO_96M", set_tcxo_96m_reset, is_tcxo_96m_locked, NULL, NULL);


    //
    // Bring up clk ClkWiz
    //
	bring_up_clock(gpiops, "clk", set_clk_reset, is_clk_locked, clk_fmeas_enable, clk_fmeas_count);
	double clk_freq = measure_frequency(gpiops);
	xil_printf("");

	// Measure frequency here

    //
    // Bring up mclk ClkWiz
    //
	bring_up_clock(gpiops, "mclk", set_mclk_reset, is_mclk_locked);
	// Measure frequency here




    //
    // Enable system
    //
	set_sys_reset(0);



}