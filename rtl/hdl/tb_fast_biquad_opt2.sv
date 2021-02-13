`timescale 1ps / 1ps


module tb_fast_biquad_opt2();
    
    
localparam SAMPLE_WIDTH = 18;
localparam COEF_WIDTH = 30;
localparam COEF_INT_WIDTH = 4;

    
reg clk = 1'b1;
always #5000 clk <= !clk;  
    
   
reg reset = 1'b1;
initial #1010000 reset <= 1'b0;
    

/*
reg signed [COEF_WIDTH-1:0] b0 = 0.85762 * 2**(COEF_WIDTH-COEF_INT_WIDTH); //2**13 ;
//reg signed [COEF_WIDTH-1:0] b1 = -0.85762 * 2**(COEF_WIDTH-COEF_INT_WIDTH);//2**11;
reg signed [COEF_WIDTH-1:0] b1 = -0.8 * 2**(COEF_WIDTH-COEF_INT_WIDTH);//2**11;
reg signed [COEF_WIDTH-1:0] b2 = 0;//2**11;
     
reg signed [COEF_WIDTH-1:0] a1 = 0.715 * 2**(COEF_WIDTH-COEF_INT_WIDTH);//2**12;
reg signed [COEF_WIDTH-1:0] a2 = 0;//2**12;
*/

/*
reg signed [COEF_WIDTH-1:0] b0 = 0.850 * 2**(COEF_WIDTH-COEF_INT_WIDTH); //2**13 ;
//reg signed [COEF_WIDTH-1:0] b1 = -0.85762 * 2**(COEF_WIDTH-COEF_INT_WIDTH);//2**11;
reg signed [COEF_WIDTH-1:0] b1 = -0.750 * 2**(COEF_WIDTH-COEF_INT_WIDTH);//2**11;
reg signed [COEF_WIDTH-1:0] b2 = 0;//2**11;
     
reg signed [COEF_WIDTH-1:0] a1 = 0.000 * 2**(COEF_WIDTH-COEF_INT_WIDTH);//2**12;
reg signed [COEF_WIDTH-1:0] a2 = 0;//2**12;
*/


reg signed [COEF_WIDTH-1:0] b0 = 4.750 * 2**(COEF_WIDTH-COEF_INT_WIDTH); //2**13 ;
//reg signed [COEF_WIDTH-1:0] b1 = -0.85762 * 2**(COEF_WIDTH-COEF_INT_WIDTH);//2**11;
reg signed [COEF_WIDTH-1:0] b1 = -3.750 * 2**(COEF_WIDTH-COEF_INT_WIDTH);//2**11;
reg signed [COEF_WIDTH-1:0] b2 = 0;//2**11;
     
reg signed [COEF_WIDTH-1:0] a1 = 0.000 * 2**(COEF_WIDTH-COEF_INT_WIDTH);//2**12;
reg signed [COEF_WIDTH-1:0] a2 = 0;//2**12;




//reg [SAMPLE_WIDTH-1:0] in;
wire in_valid = !reset;

wire signed [SAMPLE_WIDTH-1:0] out; 
wire out_valid;
    
    
wire signed [SAMPLE_WIDTH-1:0] out_opt; 
wire out_valid_opt;
    
    
    
//wire signed [SAMPLE_WIDTH-1:0] out_mix = in_d3 + out_opt; 

    
    
reg [8:0] count = 0;
always @(posedge clk) count <= count + 1;     
        
wire signed [31:0] sig_p;
//wire signed [SAMPLE_WIDTH-1:0] in = (sig_p > 0) ? 1000 : -1000;
//wire signed [SAMPLE_WIDTH-1:0] in = (count == 0) ? 100 : 0;
wire signed [SAMPLE_WIDTH-1:0] in = sig_p;
    
    
reg mclk = 1'b0;
always #(1e12/9.728e6) mclk <= !mclk;


reg [31:0] mclk_div = 0;
always @(posedge mclk) mclk_div <= mclk_div + 1;

wire mclk_38khz_valid = !reset && (mclk_div[6:0] == 0);
    
    
    
gen_tone
#(

    // Tone
    .AMPL(1000e-6),
    .FREQ(20),
    .SAMPLE_RATE(38e3),
    .PHASE_DELTA_INC(0.003)
//    .PHASE_DELTA_INC(0.0)
    /*
    // White noise
    .AMPL(0),
    .CM_NOISE_AMPL(127e-6),
    .SAMPLE_RATE(25e6)
    */
)
siggen_a 
(
    .sig_p_uv(sig_p)
);
    
    
    
    
    
    /*
fast_biquad_opt2
#(
    .SAMPLE_WIDTH(SAMPLE_WIDTH),
    .COEF_WIDTH(COEF_WIDTH),
    .COEF_INT_WIDTH(COEF_INT_WIDTH)
    
)
dut_opt
(
    .clk(mclk),
    .reset(reset),
    
    .b0(b0),
    .b1(b1),
    .b2(b2),
    .a1(a1),
    .a2(a2),
    
    .in(in),
    .in_valid(mclk_38khz_valid),
    
    .out(out_opt),
    .out_valid(out_valid_opt)
);   

*/






localparam PREEMPH_SAMPLE_WIDTH = 18;
localparam PREEMPH_COEF_WIDTH = 30;
localparam PREEMPH_COEF_INT_WIDTH = 4;

fast_biquad_opt2
#(
    .SAMPLE_WIDTH(PREEMPH_SAMPLE_WIDTH),
    .COEF_WIDTH(PREEMPH_COEF_WIDTH),
    .COEF_INT_WIDTH(PREEMPH_COEF_INT_WIDTH)
    
)
preemph_50us_38khz
(
    .clk(mclk),
    .reset(reset),
    
    .b0(2.375 * 2**(PREEMPH_COEF_WIDTH-PREEMPH_COEF_INT_WIDTH)),
    .b1(-1.8750 * 2**(PREEMPH_COEF_WIDTH-PREEMPH_COEF_INT_WIDTH)),
    .b2(0),
    .a1(0.5 * 2**(PREEMPH_COEF_WIDTH-PREEMPH_COEF_INT_WIDTH)),
    .a2(0),
    
    .in(in),
    .in_valid(mclk_38khz_valid),
    
    .out(out_opt),
    .out_valid(out_valid_opt)
);   










    
    
endmodule
