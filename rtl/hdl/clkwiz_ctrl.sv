`timescale 1ps / 1ps



// FEATURES:
// - BUFGMUX to select one of two input clocks
// - ClkWiz reset CDC - resynchronizes PS domain reset to ClkWiz clkin domain
// - ClkWiz locked CDC - resynchronizes ClkWiz domain locked to PS domain
// - system reset CDC - resynchronizes PS domain reset to ClkWiz clkout0 domain
// - frequency measurement - counts the number of clk cycles within a fixed time interval



module clkwiz_ctrl (

    // From Zynq AP
    input pl_clk0,
    input pl_reset_n,    // pl_clk0 domain    -   resets entire PL
    input clk_reset,     // pl_clk0 domain    -   resets ClkWiz IP only
    input sys_reset,     // pl_clk0 domain    -   resets clk domain logic
    
    // Inputs to BUFGMUX
    input clk0,
    input clk1,
    input clkin_src_sel, // pl_clk0 domain    

    // MMCM/clkwiz interface
    output clkwiz_clkin,
    output clkwiz_reset,    
    input clkwiz_clkout0,
    input clkwiz_clkout1,
    input clkwiz_locked,
    
    // To PL design
    output clk,
    output reset,       // clk domain    
    
    // To AP
    output clk_locked,  // pl_clk0 domain    
    
    // To AP
    input fmeas_enable, // pl_clk0 domain
    output [23:0] fmeas_count  // pl_clk0 domain
    
);
    
    
    
    
BUFGMUX clkwiz_clkin_bufgmux (
    .I0(clk0),
    .I1(clk1),
    .O(clkwiz_clkin),
    .S(clkin_src_sel) 
);




xpm_cdc_sync_rst #(
    .DEST_SYNC_FF(2),  
    .INIT(1),           
    .INIT_SYNC_FF(0),  
    .SIM_ASSERT_CHK(0) 
)
clkwiz_reset_cdc (
    .src_rst(   !pl_reset_n  ||   clk_reset  ),  
    .dest_clk(clkwiz_clkin),
    .dest_rst(clkwiz_reset)
);






xpm_cdc_sync_rst #(
    .DEST_SYNC_FF(2),  
    .INIT(1),           
    .INIT_SYNC_FF(0),  
    .SIM_ASSERT_CHK(0) 
)
clk_locked_cdc (
    .src_rst(  clkwiz_locked  ),  
    .dest_clk(pl_clk0),
    .dest_rst(clk_locked)
);



wire sys_reset_synced;


xpm_cdc_sync_rst #(
    .DEST_SYNC_FF(2),  
    .INIT(1),           
    .INIT_SYNC_FF(0),  
    .SIM_ASSERT_CHK(0) 
)
sys_reset_cdc (
    .src_rst(  sys_reset  ),  
    .dest_clk(clk),
    .dest_rst(sys_reset_synced)
);


assign clk = clkwiz_clkout0;
assign reset = !clkwiz_locked || sys_reset_synced;
    
    
    
    

freq_meas clk_freq_meas (

    .clk(pl_clk0),
    .reset(!pl_reset_n),
    
    .test_clk(clk),
    .test_reset(reset),
    
    .fmeas_enable(fmeas_enable),
    .fmeas_count(fmeas_count)
    
    
);
    
    
    
    
    
endmodule
