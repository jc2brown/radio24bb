
#ifndef CLOCK_RESET_H
#define CLOCK_RESET_H

#include "xgpiops.h"
#include "clkwiz.h"


struct clock_reset {
	XGpioPs *gpiops;
	struct clkwiz *clk_clkwiz;
	struct clkwiz *mclk_clkwiz;
};



struct clock_reset *make_clock_reset();
int init_clock_reset(struct clock_reset *clkrst, XGpioPs *gpiops);




void set_clk_frequency(struct clock_reset *clkrst, int clkin_sel, uint64_t target_clkout_hz);
void set_mclk_frequency(struct clock_reset *clkrst, int clkin_sel, uint64_t target_clkout_hz);



#define clkrst_trace xil_printf
// #define clkrst_trace(...)

#endif
