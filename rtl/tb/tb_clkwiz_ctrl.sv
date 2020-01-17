`timescale 1ps / 1ps


module tb_clkwiz_ctrl();
    
    
    
reg pl_clk0 = 1;
always #5000 pl_clk0 <= !pl_clk0;

reg pl_reset_n = 0;
initial #100000 pl_reset_n <= 1;

    
    
reg TCXO_96M = 1;
always #5208 TCXO_96M <= !TCXO_96M; 

    
    
    
    
    
reg clk_reset = 0; // ClkWiz reset from gpiops
reg sys_reset = 0; // PL system reset from gpiops, excludes MMCMs
    
reg clkin_src_sel = 0; // From gpiops

    

wire clkwiz_clkin;
wire clkwiz_reset;    
wire clkwiz_clkout0;
wire clkwiz_clkout1;
wire clkwiz_locked;
    

wire clk;
wire reset;

wire clk_locked;



reg fmeas_enable = 0;
wire [23:0]fmeas_count;


    
clkwiz_ctrl dut (

    // From Zynq AP
    .pl_clk0(pl_clk0),
    .pl_reset_n(pl_reset_n),    // pl_clk0 domain    -   resets entire PL
    .clk_reset(clk_reset),     // pl_clk0 domain    -   resets ClkWiz IP only
    .sys_reset(sys_reset),     // pl_clk0 domain    -   resets clk domain logic
    
    // Inputs to BUFGMUX
    .clk0(pl_clk0),
    .clk1(TCXO_96M),
    .clkin_src_sel(clkin_src_sel), // pl_clk0 domain    

    // clkwiz/clkwiz interface
    .clkwiz_clkin(clkwiz_clkin),
    .clkwiz_reset(clkwiz_reset),    
    .clkwiz_clkout0(clkwiz_clkout0),
    .clkwiz_clkout1(clkwiz_clkout1),
    .clkwiz_locked(clkwiz_locked),
    
    // To PL design
    .clk(clk),
    .reset(reset),       // clk domain    
    
    // To AP
    .clk_locked(clk_locked),  // pl_clk0 domain    
    
    // To AP
    .fmeas_enable(fmeas_enable), // pl_clk0 domain
    .fmeas_count(fmeas_count)  // pl_clk0 domain
    
);
    
    
    
    
clk_wiz_0 clkwiz0 (
    .clk_in1(clkwiz_clkin),
    .reset(clkwiz_reset),
    .clk_out1(clkwiz_clkout0),
    .locked(clkwiz_locked)
);




initial begin

    // In the final design, this logic is handled by the AP



    clk_reset <= 1;
    sys_reset <= 1;
    
    // Enable MMCM 1us after exiting pl_reset_n
    @(posedge pl_reset_n) #1000000 @(posedge pl_clk0) clk_reset <= 0;
    
    // Enable PL 1us after MMCM locks
    @(posedge clk_locked) #1000000 @(posedge pl_clk0) sys_reset <= 0;



end

    
    
    
    
endmodule
