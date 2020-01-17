

#include "xclk_wiz.h"





void set_clkwiz_freq(XClkWiz *clkwiz) {
	

	uint64_t DIVCLK_DIVIDE = 1; // [7:0] - D value
	uint64_t CLKFBOUT_MULT = 1; // [15:8] - Integer part of M
	uint64_t CLKFBOUT_FRAC = 0; // [25:16] - fractional part of M, times 1000


	uint64_t C_BASEADDR = 0xFFFFFFFF; // ClkWiz base address

	// Clock Configuration Register 0
	*((volatile uint32_t *)(C_BASEADDR+0x200)) = 
		((DIVCLK_DIVIDE & 0x0FF) << 0) |
		((CLKFBOUT_MULT & 0x0FF) << 8) |
		((CLKFBOUT_FRAC & 0x3FF) << 16);


	// Clock Configuration Register 1
	// *((volatile uint32_t *)(C_BASEADDR+0x204)) = 
	// [31:0] CLKFBOUT_PHASE - leave as default 0






	uint64_t CLKOUT0_DIVIDE = 1; // [7:0] - Integer part of O0
	uint64_t CLKOUT0_FRAC = 0; // [17:8] - fractional part of O0, times 1000

	// Clock Configuration Register 2
	*((volatile uint32_t *)(C_BASEADDR+0x208)) = 
		((CLKOUT0_DIVIDE & 0x0FF) << 0) |
		((CLKFBOUT_MULT & 0x0FF) << 8) |
		((CLKFBOUT_FRAC & 0x3FF) << 16);



	uint64_t CLKOUT0_PHASE = 0;

	// Clock Configuration Register 3

	*((volatile uint32_t *)(C_BASEADDR+0x20C)) = ;




	// Clock Configuration Register 4

	*((volatile uint32_t *)(C_BASEADDR+0x210)) = ;


	// Bit[31:0] = CLKOUT0_DUTY
	// Duty cycle value = (Duty Cycle in %) * 1000
	// For example, for 50% duty cycle, value is 50000 = 0xC350

	*((volatile uint32_t *)(C_BASEADDR+0x214)) = ;






	// Clock Configuration Register 1
	// [31:0] CLKFBOUT_PHASE - leave as default 0

		



}