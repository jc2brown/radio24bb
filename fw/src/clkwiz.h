

#ifndef CLKWIZ_H
#define CLKWIZ_H

#include "xclk_wiz.h"
#include "xgpiops.h"


#define TCXO_19M2_FREQ ((double)19.2e6)
#define TCXO_96M_FREQ ((double)96e6)
#define PL_CLK0_FREQ  ((double)100e6)






// This strucuture is used as a workspace for calculating optimal MMCM/PLL multiplier and divider values.
struct clkwiz_cfg {
    
//
// Fixed hardware limits
//
    // VCO operating frequency
    uint64_t vco_min_hz;
    uint64_t vco_max_hz;

    // clkin divider range
    uint64_t clkin_div_min;
    uint64_t clkin_div_max;

    // clkfb multiplier range
    uint64_t clkfb_mult_min;
    uint64_t clkfb_mult_max;

    // clkout divider range
    uint64_t clkout_div_min;
    uint64_t clkout_div_max;


//
// Intermediate calculation results
//
    // Range of clkfb multipler values which yield valid VCO frequencies
    // Stored values have a fractional resolution equal to nfrac. Divide by nfrac (without rounding) to get true range
    uint64_t clkfb_min_mult_x_nfrac;
    uint64_t clkfb_max_mult_x_nfrac;

    // Range of clkout divider values which the target clkout frequency  multipler values which yield valid VCO frequencies
    uint64_t clkout_min_div_x_nfrac;
    uint64_t clkout_max_div_x_nfrac;


//
// Application requirements 
//
    uint64_t nfrac; // Number of fractional counts (0 <= nfrac <= 8)
    uint64_t clkin_sel;
    uint64_t clkin_hz;
    uint64_t target_clkout_hz;


//
// Results
// 
    uint64_t D;
    uint64_t M_x_nfrac;
    uint64_t O0_x_nfrac;
    

//
// Analysis
//
    uint64_t divclk_hz;
    uint64_t vco_hz;
    uint64_t clkout_hz;
    uint64_t error_hz;
};





// This structure matches the register space of the ClkWiz HDL IP 
struct clkwiz_regs {
	volatile uint32_t reset; 			// 0x000
	volatile uint32_t status; 			// 0x004 
	volatile uint32_t mon_status;		// 0x008
	volatile uint32_t intr_status;		// 0x00C
	volatile uint32_t intr_en; 			// 0x010
	volatile uint32_t reserved0[123];  	// 0x014-0x1FC
	volatile uint32_t divmult;			// 0x200
	volatile uint32_t clkfbout_phase;	// 0x204
	volatile uint32_t clkout0_divide;	// 0x208
	volatile uint32_t clkout0_phase;	// 0x20C
	volatile uint32_t clkout0_duty;		// 0x210
	volatile uint32_t clkout1_divide;	// 0x214
	volatile uint32_t clkout1_phase;	// 0x218
	volatile uint32_t clkout1_duty;		// 0x21C
};




struct clkwiz {
	XClk_Wiz *xclkwiz;
    XGpioPs *gpiops;
	struct clkwiz_cfg cfg;
	struct clkwiz_regs *regs;    
    uint64_t clkin1_hz;
    uint64_t clkin2_hz;
    int clkin_sel_pin; // xgpiops pin
    int clkin_sel;
};




struct clkwiz *make_clkwiz();

int init_clkwiz(
    struct clkwiz *wiz, 
    XGpioPs *gpiops, 
    int device_id, 
    uint64_t clkin1_hz, 
    uint64_t clkin2_hz,
    int clkin_sel_pin
);


void clkwiz_set_frequency(struct clkwiz *wiz, int clikin_sel, uint64_t target_clkout_hz);


// #define clkwiz_trace(...)
#define clkwiz_trace xil_printf


#endif