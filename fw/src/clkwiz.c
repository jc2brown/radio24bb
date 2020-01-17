
#include "xclk_wiz.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xscugic.h"
#include "xil_printf.h"
#include "sleep.h"
#include "ClkWiz.h"


#define CLKWIZ_CLKIN_FREQ  (XPAR_PSU_CORTEXA53_0_TIMESTAMP_CLK_FREQ / 1000)  // KHz



int Wait_For_Lock(XClk_Wiz *clkwiz) {
    u32 Count = 0;
    while(!(*(u32 *)(clkwiz->Config.BaseAddr + 0x04))) {
        if(Count == 10000) {
            return XST_FAILURE;
        }
        Count++;
    }
    return XST_SUCCESS;
}




// Configure a ClkWiz IP block to generate two clocks at the same frequency
// with clkout1 lagging clkout0 by 90 degrees.
//
// Assumptions:
// - the IP is configured for output on clkout0 and clkout1
// - software has already initialized the ClkWiz driver with InitClkWiz()
//
// Users must calculate and supply an appropriate value for vco_khz based on the
// fixed input clock frequency and the desired output frequency.
//
// The valid range for vco_khz is 800000 to 1600000.
//
// In general, vco_khz should be chosen such that the following relationships are integers or half-integers:
// - input frequency to VCO frequency
// - VCO frequency to output frequency
//
// Examples:
// - For an input clock at 100MHz and an output frequency of 50MHz, 100MHz, or 200MHz, use vco_khz=800000.
// - For an input clock at 100MHz and an output frequency of 150MHz, use vco_khz=900000.
// - For an input clock at 100MHz and an output frequency of 250MHz, use vco_khz=1000000.
//
int ConfigClkWizQuadrature(XClk_Wiz *clkwiz, u32 vco_khz, u32 clkout_khz) {

    u32 clkin_factor = CLKWIZ_CLKIN_FREQ * 10;
    u32 vco_factor = vco_khz * 10;
    u32 clkout_factor = clkout_khz * 10;

    u32 Error = 0;
    u32 Fail  = 0;
    u32 Frac_en = 0;
    u32 Frac_divide = 0;
    u32 Divide = 0;
    float Freq = 0.0;

    XClk_Wiz_Config *cfg = &(clkwiz->Config);
    if (!cfg) {
        xil_printf("ReconfigClkWiz: *cfg == NULL\r\n");
        return XST_FAILURE;
    }

    Fail = Wait_For_Lock(clkwiz);
    if (Fail) {
        Error++;
        xil_printf("\n ERROR: Clock is not locked for default frequency : 0x%x\n\r", *(u32 *)(cfg->BaseAddr + 0x04));
    }

    // SW reset applied
    *(u32 *)(cfg->BaseAddr + 0x00) = 0xA;

    if (*(u32 *)(cfg->BaseAddr + 0x04)) {
        Error++;
        xil_printf("\n ERROR: Clock is locked : 0x%x \t expected 0x00\n\r", *(u32 *)(cfg->BaseAddr + 0x04));
    }

    // Wait cycles after SW reset
    usleep(100);

    Fail = Wait_For_Lock(clkwiz);
    if (Fail) {
        Error++;
        xil_printf("\n ERROR: Clock is not locked after SW reset: 0x%x \t Expected  : 0x1\n\r",
        *(u32 *)(cfg->BaseAddr + 0x04));
    }

    // Calculation of Input Freq and Divide factors
    Freq = vco_factor / clkin_factor;

    Divide = Freq;
    Freq = (float)(Freq - Divide);

    Frac_divide = Freq * 10000;

    if (Frac_divide % 10 > 5) {
       Frac_divide = Frac_divide + 10;
    }
    Frac_divide = Frac_divide/10;

    if (Frac_divide > 1023 ) {
       Frac_divide = Frac_divide / 10;
    }

    if (Frac_divide) {
       Frac_en = (1 << 26);
    }
    else {
       Frac_en = 0;
    }

    // Configuring Multiply and Divide values
    *(u32 *)(cfg->BaseAddr + 0x200) = Frac_en | (Frac_divide << 16) | (Divide << 8) | 0x01;
    *(u32 *)(cfg->BaseAddr + 0x204) = 0x00;

    // Calculation of Output Freq and Divide factors
    Freq = vco_factor / clkout_factor;

    Divide = Freq;
    Freq = (float)(Freq - Divide);

    Frac_divide = Freq * 10000;

    if (Frac_divide % 10 > 5) {
        Frac_divide = Frac_divide + 10;
    }
    Frac_divide = Frac_divide / 10;

    if(Frac_divide > 1023 ) {
        Frac_divide = Frac_divide / 10;
    }

    if (Frac_divide) {
        // if fraction part exists, Frac_en is shifted to 18 for output Freq
        Frac_en = (1 << 18);
    }
    else {
        Frac_en = 0;
    }

    // Configuring Multiply and Divide values for clk0
    *(u32 *)(cfg->BaseAddr +0x208) = Frac_en | (Frac_divide << 8) | (Divide); // frequency
    *(u32 *)(cfg->BaseAddr + 0x20C) = 0 * 1000; // phase

    // Configuring Multiply and Divide values for clk1
    *(u32 *)(cfg->BaseAddr +0x214) = Frac_en | (Frac_divide << 8) | (Divide); // frequency
    *(u32 *)(cfg->BaseAddr + 0x218) = 90 * 1000; // phase

    // Load Clock Configuration Register values
    *(u32 *)(cfg->BaseAddr + 0x25C) = 0x07;

    if (*(u32 *)(cfg->BaseAddr + 0x04)) {
        Error++;
        xil_printf("\n ERROR: Clock is locked : 0x%x \t expected 0x00\n\r", *(u32 *)(cfg->BaseAddr + 0x04));
     }

     // Clock Configuration Registers are used for dynamic reconfiguration
     *(u32 *)(cfg->BaseAddr + 0x25C) = 0x02;

    Fail = Wait_For_Lock(clkwiz);
    if (Fail) {
        Error++;
        xil_printf("\n ERROR: Clock is not locked : 0x%x \t Expected : 0x1\n\r", *(u32 *)(cfg->BaseAddr + 0x04));
    }
    xil_printf("ReconfigClkWiz: return %d\r\n", Error);
    return Error;
}




u32 InitClkWiz(XClk_Wiz *clkwiz, u32 device_id) {

    u32 Status = XST_SUCCESS;

    XClk_Wiz_Config *cfg = XClk_Wiz_LookupConfig(device_id);
    if (!cfg) {
        return XST_FAILURE;
    }

    Status = XClk_Wiz_CfgInitialize(clkwiz, cfg, cfg->BaseAddr);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    return XST_SUCCESS;

}



