`timescale 1ps / 1ps


module tb_clock_reset( );
    
    
    

wire [63:0] gpiops_o;
wire [63:0] gpiops_i;

    
    
reg sys_reset;
assign gpiops_o[0] = sys_reset;

reg tcxo_96m_reset;
assign gpiops_o[2] = tcxo_96m_reset;

wire tcxo_96m_locked = gpiops_i[3];




localparam CLK_BASE_PIN = 4;


reg clk_reset;
assign gpiops_o[CLK_BASE_PIN+0] = clk_reset;

reg clk_src_sel;
assign gpiops_o[CLK_BASE_PIN+1] = clk_src_sel;

wire clk_locked = gpiops_i[CLK_BASE_PIN+2];

reg clk_fmeas_en;
assign gpiops_o[CLK_BASE_PIN+3] = clk_fmeas_en;

wire [23:0] clk_fmeas_count = gpiops_i[CLK_BASE_PIN+27:CLK_BASE_PIN+4];





localparam MCLK_BASE_PIN = 34;


reg mclk_reset;
assign gpiops_o[MCLK_BASE_PIN+0] = mclk_reset;

reg mclk_src_sel;
assign gpiops_o[MCLK_BASE_PIN+1] = mclk_src_sel;

wire mclk_locked = gpiops_i[MCLK_BASE_PIN+2];

reg mclk_fmeas_en;
assign gpiops_o[MCLK_BASE_PIN+3] = mclk_fmeas_en;

wire [23:0] mclk_fmeas_count = gpiops_i[MCLK_BASE_PIN+27:MCLK_BASE_PIN+4];




    
    

reg clk_clkwiz_clkin;
reg clk_clkwiz_reset;    
wire clk_clkwiz_clkout0;
wire clk_clkwiz_clkout1;
wire clk_clkwiz_locked;
        
reg mclk_clkwiz_clkin;
reg mclk_clkwiz_reset;    
wire mclk_clkwiz_clkout0;
wire mclk_clkwiz_clkout1;
wire mclk_clkwiz_locked;



    
reg pl_clk0 = 1;
always #5000 pl_clk0 <= !pl_clk0;

reg pl_reset_n = 0;
initial #100000 pl_reset_n <= 1;

    
    
reg TCXO_19M2 = 1;
always #26042 TCXO_19M2 <= !TCXO_19M2; 

    

wire clk;
wire reset;

wire mclk;
wire mreset;




initial begin
    
    tcxo_96m_reset <= 1;
    clk_reset <= 1;
    mclk_reset <= 1;
    sys_reset <= 1;


    @(posedge pl_reset_n);
    @(posedge pl_clk0);
    
    
    
    //
    // Bring up 19.2MHz -> 96MHz PLL
    //
    @(posedge pl_clk0) tcxo_96m_reset <= 0;
    do @(posedge pl_clk0); while (!tcxo_96m_locked); 
    repeat(1000) #1000;  // Wait 1us
    
    
    //
    // Bring up clk_mmcm
    //
    @(posedge pl_clk0) clk_fmeas_en <= 0;
    @(posedge pl_clk0) clk_src_sel <= 0;
    @(posedge pl_clk0) clk_reset <= 0;
    do @(posedge pl_clk0); while (!clk_locked); 
    repeat(1000) #1000;  // Wait 1us
    
        
    //
    // Bring up mclk_mmcm
    //
    @(posedge pl_clk0) mclk_fmeas_en <= 0;
    @(posedge pl_clk0) mclk_src_sel <= 1;
    @(posedge pl_clk0) mclk_reset <= 0;
    do @(posedge pl_clk0); while (!mclk_locked); 
    repeat(1000) #1000;  // Wait 1us
    


    //
    // Bring system out of reset
    //    
    @(posedge pl_clk0) sys_reset <= 0;
    repeat(1000) #1000;  // Wait 1us




    //
    // Measure clock frequencies
    //    
    @(posedge pl_clk0) clk_fmeas_en <= 1;
    @(posedge pl_clk0) mclk_fmeas_en <= 1;
    
//    repeat(120) repeat(1000) repeat(1000) #1000;  // Wait 120ms
    repeat(1200) repeat(1000) #1000;  // Wait 1200us
    
    
    
    $display( " mclk freq: %e ",   100e6 * mclk_fmeas_count / 100_000);
    
    //@(posedge pl_clk0) mclk_fmeas_count <= 1;
    
    
    
    $finish();
    

end






clock_reset dut (

    .pl_clk0(pl_clk0),
    .pl_reset_n(pl_reset_n),
    
    .TCXO_19M2(TCXO_19M2),
    
    .clk(clk),
    .reset(reset),
    
    .mclk(mclk),
    .mreset(mreset),
    
    
    .gpiops_o(gpiops_o),
    .gpiops_i(gpiops_i),
    
    
    
    .clk_clkwiz_clkin(clk_clkwiz_clkin),
    .clk_clkwiz_reset(clk_clkwiz_reset),    
    .clk_clkwiz_clkout0(clk_clkwiz_clkout0),
    .clk_clkwiz_clkout1(clk_clkwiz_clkout1),
    .clk_clkwiz_locked(clk_clkwiz_locked),
        
    .mclk_clkwiz_clkin(mclk_clkwiz_clkin),
    .mclk_clkwiz_reset(mclk_clkwiz_reset),    
    .mclk_clkwiz_clkout0(mclk_clkwiz_clkout0),
    .mclk_clkwiz_clkout1(mclk_clkwiz_clkout1),
    .mclk_clkwiz_locked(mclk_clkwiz_locked)


);
    
    
    
clk_clkwiz clk_clkwiz_inst (
    .clk_in1(clk_clkwiz_clkin),
    .reset(clk_clkwiz_reset),
    .clk_out1(clk_clkwiz_clkout0),
    .clk_out2(clk_clkwiz_clkout1),
    .locked(clk_clkwiz_locked)
);    
    
    
    
mclk_clkwiz mclk_clkwiz_inst (
    .clk_in1(mclk_clkwiz_clkin),
    .reset(mclk_clkwiz_reset),
    .clk_out1(mclk_clkwiz_clkout0),
    .clk_out2(mclk_clkwiz_clkout1),
    .locked(mclk_clkwiz_locked)
);    
    
    
    
    
    
    
endmodule
