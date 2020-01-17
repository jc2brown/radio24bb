
#include <stdio.h>
#include <stdint.h>



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





struct ClkWiz_Cfg {
    
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
    uint64_t clkin_hz;
    uint64_t target_clkout_hz;


//
// Results
// 
    uint64_t D;
    uint64_t M;
    uint64_t O0;
    

//
// Analysis
//
    uint64_t divclk_hz;
    uint64_t vco_hz;
    uint64_t clkout_hz;
    uint64_t error_hz;
};






void dump_clkwiz_cfg(struct ClkWiz_Cfg *cfg) {

    printf("\n");
    printf("###################################\n");

    printf("vco_min_hz=%lu\n", cfg->vco_min_hz);
    printf("vco_max_hz=%lu\n", cfg->vco_max_hz);

    printf("clkin_div_min=%lu\n", cfg->clkin_div_min);
    printf("clkin_div_max=%lu\n", cfg->clkin_div_max);

    printf("clkfb_mult_min=%lu\n", cfg->clkfb_mult_min);
    printf("clkfb_mult_max=%lu\n", cfg->clkfb_mult_max);

    printf("clkout_div_min=%lu\n", cfg->clkout_div_min);
    printf("clkout_div_max=%lu\n", cfg->clkout_div_max);


    printf("clkfb_min_mult_x_nfrac=%lu\n", cfg->clkfb_min_mult_x_nfrac);
    printf("clkfb_max_mult_x_nfrac=%lu\n", cfg->clkfb_max_mult_x_nfrac);

    printf("clkout_min_div_x_nfrac=%lu\n", cfg->clkout_min_div_x_nfrac);
    printf("clkout_max_div_x_nfrac=%lu\n", cfg->clkout_max_div_x_nfrac);


    printf("nfrac=%lu\n", cfg->nfrac);
    printf("clkin_hz=%lu\n", cfg->clkin_hz);
    printf("target_clkout_hz=%lu\n", cfg->target_clkout_hz);

    printf("D=%lu\n", cfg->D);
    printf("M=%lu\n", cfg->M);
    printf("O0=%lu\n", cfg->O0);


    printf("divclk_hz=%lu\n", cfg->divclk_hz);
    printf("vco_hz=%lu\n", cfg->vco_hz);
    printf("clkout_hz=%lu\n", cfg->clkout_hz);
    printf("error_hz=%lu\n", cfg->error_hz);

    printf("###################################\n");
    printf("\n");
    

}





// nfrac: resolution of fractional portion of multipliers/dividers. Typically 8 for normal operation, 1 for whole-integer-only ratios
// D: prescale divider value
struct ClkWiz_Cfg make_clkwiz_cfg(uint64_t clkin_hz, uint64_t target_clkout_hz, uint64_t nfrac, uint64_t D) {

    struct ClkWiz_Cfg cfg;

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
    cfg.D = D;
    cfg.clkin_hz = clkin_hz;
    cfg.target_clkout_hz = target_clkout_hz;
    cfg.divclk_hz = clkin_hz / D;


    return cfg;
}





// Find the range of clkfb multiplier values which would yield valid
// VCO frequencies if applied to the predivided input clock.
void get_clkfb_mult_space(struct ClkWiz_Cfg *cfg) {

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
void get_clkout_div_space(struct ClkWiz_Cfg *cfg) {
  
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





void find_best_clkwiz_cfg(struct ClkWiz_Cfg *cfg) {


    get_clkfb_mult_space(cfg);
    get_clkout_div_space(cfg);


    dump_clkwiz_cfg(cfg);

    
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
                printf("Perfect match\n");
                //goto end;
            }

        }
    }


end:
    printf("\n");

    cfg->M = best_i;
    cfg->O0 = best_j;

    cfg->vco_hz = (cfg->divclk_hz * cfg->M) / cfg->nfrac;
    cfg->clkout_hz = (cfg->divclk_hz * cfg->M) / cfg->O0;
    cfg->error_hz = abs(cfg->clkout_hz - cfg->target_clkout_hz);

}






int main() {

    uint64_t clkin_hz = 96e6;
    uint64_t target_clkout_hz = 9.728e6;
    uint64_t nfrac = 8;


    struct ClkWiz_Cfg best_cfg; // Intentionally uninitialized
    uint64_t best_error_hz = 1e9;
    

    // Sweep through all possible prescale divider values and remember the best ClkWiz cfg
    for (int D = CLKIN_DIV_MIN; D <= CLKIN_DIV_MAX; ++D) {
        struct ClkWiz_Cfg cfg = make_clkwiz_cfg(clkin_hz, target_clkout_hz, nfrac, D);
        find_best_clkwiz_cfg(&cfg);
        if (abs(cfg.error_hz) < best_error_hz) {
            best_error_hz = abs(cfg.error_hz);
            best_cfg = cfg;
        }
    }



    printf("Best cfg: \n");
    dump_clkwiz_cfg(&best_cfg);
    
    printf("Final results:\n");
    printf("\n");

    printf("CLKIN= %7.03f MHz\n", (double)best_cfg.clkin_hz/1e6);
    printf("CLKOUT=%7.03f MHz\n", best_cfg.clkout_hz/1e6);    
    printf("ERROR= %7.03f ppm\n", 1e6 * (double)best_cfg.error_hz / (double)best_cfg.target_clkout_hz);
    printf("\n");

    printf("D=%lu\n", best_cfg.D);
    printf("M=%1.03f\n", (double)best_cfg.M / best_cfg.nfrac);
    printf("O0=%1.03f\n", (double)best_cfg.O0 / best_cfg.nfrac);
    printf("\n");
    

    return 0;
}
