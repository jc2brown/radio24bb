`timescale 1ps / 1ps


module tb_fast_biquad();
    
    
localparam SAMPLE_WIDTH = 8;
localparam COEF_WIDTH = 16;

    
reg clk = 1'b1;
always #5000 clk <= !clk;  
    
   
reg reset = 1'b1;
initial #51000 reset <= 1'b0;
    

// Coefficients are signed fixed-point values with a range of [-2, 2)
// Examples (assuming COEF_WIDTH==16):
//    2**13-1  =>   0.999  (approx.)
//    2**13    =>   1.0
//    2**14-1  =>   1.999  (approx.)
//    2**14    =>  -2.0
//    2**15-1  =>  -1.001  (approx.)
//    2**15    =>  -1.0
//    2**16-1  =>  -0.001  (approx.)
//
//
reg signed [COEF_WIDTH-1:0] b0 = 0 ;
reg signed [COEF_WIDTH-1:0] b1 = 2**11;
reg signed [COEF_WIDTH-1:0] b2 = 2**11;
     
reg signed [COEF_WIDTH-1:0] a1 = 2**12;
reg signed [COEF_WIDTH-1:0] a2 = 2**12;



//reg [SAMPLE_WIDTH-1:0] in;
wire in_valid = !reset;

wire signed [SAMPLE_WIDTH-1:0] out; 
wire out_valid;
    
    
wire signed [SAMPLE_WIDTH-1:0] out_opt; 
wire out_valid_opt;
    
    
    
    
        
wire signed [31:0] sig_p;
wire signed [SAMPLE_WIDTH-1:0] in = (sig_p > 0) ? 63 : -64;
    
gen_tone
#(

    // Tone
    .AMPL(127e-6),
    .FREQ(1.07e6),
    .SAMPLE_RATE(100e6),
//    .PHASE_DELTA_INC(0.00003)
    .PHASE_DELTA_INC(0.0)
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
    
    
    
    
    
    
    
    
fast_biquad
#(
    .SAMPLE_WIDTH(SAMPLE_WIDTH),
    .COEF_WIDTH(COEF_WIDTH)
)
dut
(
    .clk(clk),
    .reset(reset),
    
    .b0(b0),
    .b1(b1),
    .b2(b2),
    .a1(a1),
    .a2(a2),
    
    .in(in),
    .in_valid(in_valid),
    
    .out(out),
    .out_valid(out_valid)
);   
    
    
    
    
    
    
fast_biquad_opt
#(
    .SAMPLE_WIDTH(SAMPLE_WIDTH),
    .COEF_WIDTH(COEF_WIDTH)
)
dut_opt
(
    .clk(clk),
    .reset(reset),
    
    .b0(b0),
    .b1(b1),
    .b2(b2),
    .a1(a1),
    .a2(a2),
    
    .in(in),
    .in_valid(in_valid),
    
    .out(out_opt),
    .out_valid(out_valid_opt)
);   



    
    
endmodule
