
#include "stdlib.h"
#include "xclk_wiz.h"
#include "xgpiops.h"
#include "gpiops.h"
#include "clkwiz.h"

#include "roe.h"
#include "sleep.h"


#define VCO_MIN_HZ ((double)(800e6))
#define VCO_MAX_HZ ((double)(1200e6))


#define abs(x) (((x)<0)?(-(x)):(x))


#define CLKIN_DIV_MIN 1
#define CLKIN_DIV_MAX 106

#define CLKFB_MULT_MIN 2
#define CLKFB_MULT_MAX 64

#define CLKOUT_DIV_MIN 1
#define CLKOUT_DIV_MAX 128


#define MIN(a, b) ((a)<(b)?(a):(b))
#define MAX(a, b) ((a)>(b)?(a):(b))
#define CLAMP(x, min, max)  MAX(MIN(x, max), min);



struct clkwiz *make_clkwiz() {

	struct clkwiz *wiz = (struct clkwiz *)malloc(sizeof(struct clkwiz));
	if (wiz == NULL) return NULL;

	wiz->xclkwiz = (XClk_Wiz *)malloc(sizeof(XClk_Wiz));
	if (wiz->xclkwiz == NULL) return NULL;

	// wiz->cfg = (struct clkwiz_cfg *)malloc(sizeof(struct clkwiz_cfg));
	// if (wiz->cfg == NULL) return NULL;

	return wiz;
}




void dump_clkwiz_cfg(struct clkwiz_cfg *cfg) {

    xil_printf("\n");
    xil_printf("###################################\n");

    xil_printf("vco_min_hz=%lu\n", cfg->vco_min_hz);
    xil_printf("vco_max_hz=%lu\n", cfg->vco_max_hz);

    xil_printf("clkin_div_min=%lu\n", cfg->clkin_div_min);
    xil_printf("clkin_div_max=%lu\n", cfg->clkin_div_max);

    xil_printf("clkfb_mult_min=%lu\n", cfg->clkfb_mult_min);
    xil_printf("clkfb_mult_max=%lu\n", cfg->clkfb_mult_max);

    xil_printf("clkout_div_min=%lu\n", cfg->clkout_div_min);
    xil_printf("clkout_div_max=%lu\n", cfg->clkout_div_max);


    xil_printf("clkfb_min_mult_x_nfrac=%lu\n", cfg->clkfb_min_mult_x_nfrac);
    xil_printf("clkfb_max_mult_x_nfrac=%lu\n", cfg->clkfb_max_mult_x_nfrac);

    xil_printf("clkout_min_div_x_nfrac=%lu\n", cfg->clkout_min_div_x_nfrac);
    xil_printf("clkout_max_div_x_nfrac=%lu\n", cfg->clkout_max_div_x_nfrac);


    xil_printf("nfrac=%lu\n", cfg->nfrac);
    xil_printf("clkin_hz=%lu\n", cfg->clkin_hz);
    xil_printf("target_clkout_hz=%lu\n", cfg->target_clkout_hz);

    xil_printf("D=%lu\n", cfg->D);
    xil_printf("M_x_nfrac=%lu\n", cfg->M_x_nfrac);
    xil_printf("O0_x_nfrac=%lu\n", cfg->O0_x_nfrac);


    xil_printf("divclk_hz=%lu\n", cfg->divclk_hz);
    xil_printf("vco_hz=%lu\n", cfg->vco_hz);
    xil_printf("clkout_hz=%lu\n", cfg->clkout_hz);
    xil_printf("error_hz=%lu\n", cfg->error_hz);

    xil_printf("###################################\n");
    xil_printf("\n");
    
}




// nfrac: resolution of fractional portion of multipliers/dividers. Typically 8 for normal operation, 1 for whole-integer-only ratios
struct clkwiz_cfg make_clkwiz_cfg(uint64_t clkin_hz, uint64_t target_clkout_hz, uint64_t nfrac) {

    struct clkwiz_cfg cfg;

    cfg.vco_min_hz = VCO_MIN_HZ;
    cfg.vco_max_hz = VCO_MAX_HZ;

    // clkin divider range
    cfg.clkin_div_min = CLKIN_DIV_MIN;
    cfg.clkin_div_max = CLKIN_DIV_MAX;

    // clkfb multiplier range
    cfg.clkfb_mult_min = CLKFB_MULT_MIN;
    cfg.clkfb_mult_max = CLKFB_MULT_MAX;

    // clkout divider range
    cfg.clkout_div_min = CLKOUT_DIV_MIN;
    cfg.clkout_div_max = CLKOUT_DIV_MAX;

    cfg.nfrac = nfrac;
    cfg.clkin_hz = clkin_hz;
    cfg.target_clkout_hz = target_clkout_hz;

    return cfg;
}




// Find the range of clkfb multiplier values which would yield valid
// VCO frequencies if applied to the predivided input clock.
void get_clkfb_mult_space(struct clkwiz_cfg *cfg) {

   cfg->clkfb_min_mult_x_nfrac = cfg->nfrac * cfg->vco_min_hz / cfg->divclk_hz;
    while (cfg->divclk_hz * cfg->clkfb_min_mult_x_nfrac < cfg->nfrac * cfg->vco_min_hz) {
        cfg->clkfb_min_mult_x_nfrac +=1;
    }
    cfg->clkfb_min_mult_x_nfrac = CLAMP(cfg->clkfb_min_mult_x_nfrac, cfg->clkfb_mult_min*cfg->nfrac, cfg->clkfb_mult_max*cfg->nfrac);


    cfg->clkfb_max_mult_x_nfrac = cfg->nfrac * cfg->vco_max_hz / cfg->divclk_hz;
    while (cfg->divclk_hz * cfg->clkfb_max_mult_x_nfrac > cfg->nfrac * cfg->vco_max_hz) {
        cfg->clkfb_max_mult_x_nfrac -=1;
    }
    cfg->clkfb_max_mult_x_nfrac = CLAMP(cfg->clkfb_max_mult_x_nfrac, cfg->clkfb_mult_min*cfg->nfrac, cfg->clkfb_mult_max*cfg->nfrac);

}




// Find the range of clkout divider values which could yield the 
// target output frequency if applied to a valid VCO frequency.
// In other words, if the VCO is operating anywhere within its valid range,
// the optimal clkout divider value will fall somewhere within the range calculated by this function.
void get_clkout_div_space(struct clkwiz_cfg *cfg) {
  
    cfg->clkout_min_div_x_nfrac = cfg->nfrac * cfg->vco_min_hz / cfg->target_clkout_hz;
    while ( cfg->nfrac * cfg->vco_min_hz / cfg->clkout_min_div_x_nfrac > cfg->target_clkout_hz) {
        cfg->clkout_min_div_x_nfrac += 1;
    }
    cfg->clkout_min_div_x_nfrac = CLAMP(cfg->clkout_min_div_x_nfrac, cfg->clkout_div_min*cfg->nfrac, cfg->clkout_div_max*cfg->nfrac);


    cfg->clkout_max_div_x_nfrac = cfg->nfrac * cfg->vco_max_hz / cfg->target_clkout_hz;
    while ( cfg->nfrac * cfg->vco_max_hz / cfg->clkout_max_div_x_nfrac < cfg->target_clkout_hz) {
        cfg->clkout_max_div_x_nfrac -= 1;
    }
    cfg->clkout_max_div_x_nfrac = CLAMP(cfg->clkout_max_div_x_nfrac, cfg->clkout_div_min*cfg->nfrac, cfg->clkout_div_max*cfg->nfrac);

}





void find_best_cfg_for_D(struct clkwiz_cfg *cfg, uint32_t D) {

    cfg->D = D;
    cfg->divclk_hz = cfg->clkin_hz / cfg->D;

    get_clkfb_mult_space(cfg);
    get_clkout_div_space(cfg);

    // dump_clkwiz_cfg(cfg);
    
    uint64_t nearest_hz = 0;
    uint64_t best_i = 0;
    uint64_t best_j = 1;


    for (int i = cfg->clkfb_min_mult_x_nfrac; i <= cfg->clkfb_max_mult_x_nfrac; ++i) {
        for (int j = cfg->clkout_min_div_x_nfrac; j <= cfg->clkout_max_div_x_nfrac; ++j) {

            uint64_t clkout_hz = (cfg->divclk_hz * i) / j; 

            // n.b. comparison is true on equality, so optimal results may be overwritten with equally optimal ones later in the search
            // TODO: maybe find the preferred search order combination (i.e. min-to-max or max-to-min for mult and div values) so that we can exit ASAP
            // To stop searching as soon as a perfect match is found, uncomment the `goto end` statement below
            //
            // Remember: higher VCO freq => lower output jitter
            if ( abs(clkout_hz-cfg->target_clkout_hz) <= abs(nearest_hz-cfg->target_clkout_hz) ) {
                nearest_hz = clkout_hz;
                best_i = i;
                best_j = j;
            }

            if (clkout_hz == cfg->target_clkout_hz) {
                xil_printf("Perfect match\n");
                //goto end;
            }

        }
    }


end:

    cfg->M_x_nfrac = best_i;
    cfg->O0_x_nfrac = best_j;

    cfg->vco_hz = (cfg->divclk_hz * cfg->M_x_nfrac) / cfg->nfrac;
    cfg->clkout_hz = (cfg->divclk_hz * cfg->M_x_nfrac) / cfg->O0_x_nfrac;
    cfg->error_hz = abs(cfg->clkout_hz - cfg->target_clkout_hz);

}

#include <stdio.h>


void get_best_config(struct clkwiz *wiz) {

    struct clkwiz_cfg best_cfg; // Intentionally uninitialized
    uint64_t best_error_hz = 1e9;
    
    // Sweep through all possible prescale divider values and remember the best ClkWiz cfg
    for (int D = CLKIN_DIV_MIN; D <= CLKIN_DIV_MAX; ++D) {
        struct clkwiz_cfg test_cfg = wiz->cfg;
        find_best_cfg_for_D(&test_cfg, D);
        if (abs(test_cfg.error_hz) < best_error_hz) {
            best_error_hz = abs(test_cfg.error_hz);
            best_cfg = test_cfg;
            if (best_error_hz == 0) {
            	break;
            }
        }
    }

    xil_printf("Best cfg: \n");
    dump_clkwiz_cfg(&best_cfg);
    
    wiz->cfg = best_cfg;

    xil_printf("Final results:\n");
    xil_printf("\n");

    printf("CLKIN= %7.03f MHz\n", (double)best_cfg.clkin_hz/1e6);
    printf("CLKOUT=%7.03f MHz\n", best_cfg.clkout_hz/1e6);    
    printf("ERROR= %7.03f ppm\n", 1e6 * (double)best_cfg.error_hz / (double)best_cfg.target_clkout_hz);
    xil_printf("\n");

    xil_printf("D=%lu\n", best_cfg.D);
    printf("M=%1.03f\n", (double)(best_cfg.M_x_nfrac) / best_cfg.nfrac);
    printf("O0=%1.03f\n", (double)(best_cfg.O0_x_nfrac) / best_cfg.nfrac);
    xil_printf("\n");
    
}




void write_clkwiz_regs(struct clkwiz *wiz) {


	// Set clk_sel
	gpiops_write_output_pin(wiz->gpiops, wiz->clkin_sel_pin, wiz->clkin_sel);


	struct clkwiz_cfg *cfg = &(wiz->cfg);
	struct clkwiz_regs *regs = wiz->regs;

	uint64_t DIVCLK_DIVIDE = cfg->D; // [7:0] - D value
	uint64_t CLKFBOUT_MULT = cfg->M_x_nfrac / cfg->nfrac; // [15:8] - Integer part of M
	uint64_t CLKFBOUT_FRAC = (1000ULL * (cfg->M_x_nfrac % cfg->nfrac)) / cfg->nfrac; // [25:16] - fractional part of M, times 1000

	regs->divmult = 
		((DIVCLK_DIVIDE & 0x0FF) << 0) |
		((CLKFBOUT_MULT & 0x0FF) << 8) |
		((CLKFBOUT_FRAC & 0x3FF) << 16);


	regs->clkfbout_phase = 0;


	uint64_t CLKOUT0_DIVIDE = cfg->O0_x_nfrac / cfg->nfrac; // [7:0] - Integer part of O0
	uint64_t CLKOUT0_FRAC = (1000ULL * (cfg->O0_x_nfrac % cfg->nfrac)) / cfg->nfrac; // [17:8] - fractional part of O0, times 1000
	
	regs->clkout0_divide =
		((CLKOUT0_DIVIDE & 0x0FF) << 0) |
		((CLKFBOUT_MULT & 0x0FF) << 8) |
		((CLKFBOUT_FRAC & 0x3FF) << 16);


	regs->clkout0_phase = 0;
	regs->clkout0_duty = 50000; // 50.000%

	// Match clkouts
	regs->clkout1_divide = regs->clkout0_divide;
	regs->clkout1_phase = regs->clkout0_phase;
	regs->clkout1_duty = regs->clkout1_duty;

}




int Wait_For_Lock(XClk_Wiz *clkwiz) {
    u32 Count = 0;
    while(!(*(u32 *)(clkwiz->Config.BaseAddr + 0x04))) {
        if(Count == 10000) {
            return XST_FAILURE;
        }
        usleep(10);
        Count++;
    }
    return XST_SUCCESS;
}






enum clkwiz_clk_sel {
	PL_CLK0 = 0,
	TCXO_96M = 1
};



enum clkwiz_nfrac {
	NFRAC_1,
	NFRAC_8
};




void clkwiz_set_frequency(
	struct clkwiz *wiz, 
	int clkin_sel, 
	uint64_t target_clkout_hz) 
{ 
	clkwiz_trace("Enter %s\nn", __func__);
	
	wiz->clkin_sel = clkin_sel;

	// Initialize the cfg struct with basic known info
	wiz->cfg = 
		make_clkwiz_cfg(		
			(wiz->clkin_sel == 0) ? wiz->clkin1_hz : wiz->clkin2_hz,
			target_clkout_hz, 
			NFRAC_8
		);

	// Calculate the remaining fields in the cfg struct
	get_best_config(wiz);

	// Update clkwiz registers
	write_clkwiz_regs(wiz);

    xil_printf("Waiting for lock...\n");
    while ( !(wiz->regs->status & 0x01) ) {
        usleep(1000);
    }
    xil_printf("Locked.\n");

	clkwiz_trace("Exit %s\n", __func__);
	//return XST_SUCCESS;
}




int init_clkwiz(
    struct clkwiz *wiz, 
    XGpioPs *gpiops, 
    int device_id, 
    uint64_t clkin1_hz, 
    uint64_t clkin2_hz,
    int clkin_sel_pin
) {

	wiz->gpiops = gpiops;
	wiz->clkin1_hz = clkin1_hz;
	wiz->clkin2_hz = clkin2_hz;
	wiz->clkin_sel_pin = clkin_sel_pin;

	XClk_Wiz_Config *cfg;
    _return_if_null_(cfg = XClk_Wiz_LookupConfig(device_id));
    _return_if_error_(XClk_Wiz_CfgInitialize(wiz->xclkwiz, cfg, cfg->BaseAddr));

    wiz->regs = (struct clkwiz_regs *)(cfg->BaseAddr);

    return XST_SUCCESS;
}





