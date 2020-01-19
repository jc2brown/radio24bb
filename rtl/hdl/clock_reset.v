`timescale 1ps / 1ps




module clock_reset(

    input pl_clk0,
    input pl_reset_n,
    
    input TCXO_19M2,
    
    output clk,
    output reset,
    
    output mclk,
    output mreset,
    
    input [63:0] gpiops_o,
    output [63:0] gpiops_i,
    
    
    //
    // ClkWiz interfaces
    //   
    
    output clk_clkwiz_clkin1,
    output clk_clkwiz_clkin2,
    output clk_clkwiz_clk_sel,
//    output clk_clkwiz_reset,    
    input clk_clkwiz_clkout0,
    input clk_clkwiz_clkout1,
    input clk_clkwiz_locked,
            
    output mclk_clkwiz_clkin1,
    output mclk_clkwiz_clkin2,
    output mclk_clkwiz_clk_sel,
//    output mclk_clkwiz_reset,    
    input mclk_clkwiz_clkout0,
    input mclk_clkwiz_clkout1,
    input mclk_clkwiz_locked
    

);
    
    
    
wire sys_reset = gpiops_o[0];
wire tcxo_96m_reset = gpiops_o[2];
wire tcxo_96m_locked;
assign gpiops_i[3] = tcxo_96m_locked;



localparam CLK_BASE_PIN = 4;

//wire clk_reset = gpiops_o[CLK_BASE_PIN+0];
//wire clk_src_sel = gpiops_o[CLK_BASE_PIN+1];
assign clk_clkwiz_clk_sel = gpiops_o[CLK_BASE_PIN+1];
wire clk_locked;
assign gpiops_i[CLK_BASE_PIN+2] = clk_locked;
wire clk_fmeas_en = gpiops_o[CLK_BASE_PIN+3];
wire [23:0] clk_fmeas_count;
assign gpiops_i[CLK_BASE_PIN+27:CLK_BASE_PIN+4] = clk_fmeas_count;










localparam MCLK_BASE_PIN = 34;



//wire mclk_reset = gpiops_o[MCLK_BASE_PIN+0];
//wire mclk_src_sel = gpiops_o[MCLK_BASE_PIN+1];
assign mclk_clkwiz_clk_sel = gpiops_o[MCLK_BASE_PIN+1];
wire mclk_locked;
assign gpiops_i[MCLK_BASE_PIN+2] = mclk_locked;
wire mclk_fmeas_en = gpiops_o[MCLK_BASE_PIN+3];
wire [23:0] mclk_fmeas_count;
assign gpiops_i[MCLK_BASE_PIN+27:MCLK_BASE_PIN+4] = mclk_fmeas_count;






wire tcxo_96m_pll_reset;
wire tcxo_96m_pll_clkout0;
wire tcxo_96m_pll_clkfb;
wire tcxo_96m_pll_locked;
wire TCXO_96M;


    
    
xpm_cdc_sync_rst #(
    .DEST_SYNC_FF(2),  
    .INIT(1),           
    .INIT_SYNC_FF(0),  
    .SIM_ASSERT_CHK(0) 
)
tcxo_96m_reset_cdc (
    .src_rst(tcxo_96m_reset),  
    .dest_clk(TCXO_19M2),
    .dest_rst(tcxo_96m_pll_reset)
);




// Multiply 19.2MHz by 5 to get 96MHz
PLLE2_BASE #(
    .BANDWIDTH("HIGH"),  // OPTIMIZED, HIGH, LOW
    .CLKIN1_PERIOD(52.083),   // 19.2MHz
    .CLKFBOUT_MULT(50),       // 19.2MHz clkin -> 960MHz VCO
    .CLKOUT0_DIVIDE(10),      // 960MHz VCO -> 96MHz clkout0
    .CLKFBOUT_PHASE(0.0),     // Phase offset in degrees of CLKFB, (-360.000-360.000).
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .STARTUP_WAIT("FALSE")    // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
)
tcxo_96m_pll (
    .RST(tcxo_96m_pll_reset),          
    .PWRDWN(1'b0),     
    .CLKIN1(TCXO_19M2),       
    .CLKFBOUT(tcxo_96m_pll_clkfb), 
    .CLKFBIN(tcxo_96m_pll_clkfb),           
    .CLKOUT0(tcxo_96m_pll_clkout0),     
    .LOCKED(tcxo_96m_pll_locked)    
);



BUFG tcxo_96m_bufg (
    .I(tcxo_96m_pll_clkout0),
    .O(TCXO_96M)
);


    
    
xpm_cdc_sync_rst #(
    .DEST_SYNC_FF(2),  
    .INIT(1),           
    .INIT_SYNC_FF(0),  
    .SIM_ASSERT_CHK(0) 
)
tcxo_96m_locked_cdc (
    .src_rst(tcxo_96m_pll_locked),  
    .dest_clk(pl_clk0),
    .dest_rst(tcxo_96m_locked)
);





    

clkwiz_ctrl clk_clkwiz_ctrl (

    // From Zynq AP
    .pl_clk0(pl_clk0),
    .pl_reset_n(pl_reset_n),   // pl_clk0 domain    -   resets entire PL
//    .clk_reset(clk_reset),     // pl_clk0 domain    -   resets ClkWiz IP only
    .sys_reset(sys_reset),     // pl_clk0 domain    -   resets clk domain logic
    
    // Inputs to BUFGMUX
    /*
    .clk0(pl_clk0),
    .clk1(TCXO_96M),
    .clkin_src_sel(clk_src_sel), // pl_clk0 domain    
*/
    // clkwiz/clkwiz interface
    /*
    .clkwiz_clkin1(clk_clkwiz_clkin1),
    .clkwiz_clkin2(clk_clkwiz_clkin2),
    .clkwiz_reset(clk_clkwiz_reset),    
    */
    .clkwiz_clkout0(clk_clkwiz_clkout0),
    .clkwiz_clkout1(clk_clkwiz_clkout1),
    .clkwiz_locked(clk_clkwiz_locked),
    
    // To PL design
    .clk(clk),
    .reset(reset),       // clk domain    
    
    // To AP
    .clk_locked(clk_locked),  // pl_clk0 domain    
    
    // To AP
    .fmeas_enable(clk_fmeas_en), // pl_clk0 domain
    .fmeas_count(clk_fmeas_count)  // pl_clk0 domain
    
);


    
    
    
clkwiz_ctrl mclk_clkwiz_ctrl (

    // From Zynq AP
    .pl_clk0(pl_clk0),
    .pl_reset_n(pl_reset_n),   // pl_clk0 domain    -   resets entire PL
//    .clk_reset(mclk_reset),     // pl_clk0 domain    -   resets ClkWiz IP only
    .sys_reset(sys_reset),     // pl_clk0 domain    -   resets clk domain logic
    
    // Inputs to BUFGMUX
    /*
    .clk0(pl_clk0),
    .clk1(TCXO_96M),
    .clkin_src_sel(mclk_src_sel), // pl_clk0 domain    
*/
    // clkwiz/clkwiz interface
    /*
    .clkwiz_clkin1(mclk_clkwiz_clkin1),
    .clkwiz_clkin2(mclk_clkwiz_clkin2),
    .clkwiz_reset(mclk_clkwiz_reset),    
    */
    .clkwiz_clkout0(mclk_clkwiz_clkout0),
    .clkwiz_clkout1(mclk_clkwiz_clkout1),
    .clkwiz_locked(mclk_clkwiz_locked),
    
    // To PL design
    .clk(mclk),
    .reset(mreset),       // clk domain    
    
    // To AP
    .clk_locked(mclk_locked),  // pl_clk0 domain    
    
    // To AP
    .fmeas_enable(mclk_fmeas_en), // pl_clk0 domain
    .fmeas_count(mclk_fmeas_count)  // pl_clk0 domain
    
);


    
    
    
    
    
    
    
endmodule
