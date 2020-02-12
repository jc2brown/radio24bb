`timescale 1ps / 1ps



module tb_am_demod();
    
    
    
localparam INPUT_WIDTH = 8;
localparam OUTPUT_WIDTH = 16;

    
reg clk = 1'b1;
always #5000 clk <= !clk;  
    
   
reg reset = 1'b1;
initial #51000 reset <= 1'b0;
    
    
    
    
wire in_valid = !reset;

wire [OUTPUT_WIDTH-1:0] out;
wire out_valid;


    
    
wire signed [31:0] am_p;
wire signed [INPUT_WIDTH-1:0] am = am_p;
    
    
gen_tone
#(
    .AMPL(127e-6),
    .FREQ(25e3),
    .SAMPLE_RATE(100e6)
)
siggen_b
(
    .sig_p_uv(am_p)
);





        
wire signed [31:0] sig_p;

//wire signed [INPUT_WIDTH-1:0] in = (sig_p > 0) ? 127 : -128;

// Square carrier
//wire signed [INPUT_WIDTH-1:0] in = (((sig_p > 0) ? 127 : -128) * ((am_p/2+64))) / (2**(INPUT_WIDTH-1));  
// No DC offset
wire signed [INPUT_WIDTH-1:0] in = (sig_p * ((am_p/2+64))) / (2**(INPUT_WIDTH-1));  
//wire signed [INPUT_WIDTH-1:0] in = (sig_p * ((((am_p<0)?-120:120)/2+64))) / (2**(INPUT_WIDTH-1));  
// With DC offset
//wire signed [INPUT_WIDTH-1:0] in = 64 +      (      (sig_p * ((am_p/2+64))) / (2**(INPUT_WIDTH-1))     )   / 2   ; 
    
    
    
    
gen_tone
#(

    // Tone
    .AMPL(127e-6),
    .FREQ(10.7e6),
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
    
    
    
    
    
    
    

    
    
am_demod
#(
	.INPUT_WIDTH(INPUT_WIDTH),
    .OUTPUT_WIDTH(OUTPUT_WIDTH)
)
dut
(

    .clk(clk),
    .reset(reset),

    .in(in),
    .in_valid(in_valid),
    
    .out(out),
    .out_valid(out_valid),
    
    .oversample_ratio(8)

);    
    
    
    
    
reg signed [OUTPUT_WIDTH-1:0] out_d1; 
reg signed [OUTPUT_WIDTH-1:0] out_d2; 
reg signed [OUTPUT_WIDTH-1:0] out_d3; 
 
 
always @(posedge clk) begin
    if (out_valid) begin
        out_d1 <= out;
        out_d2 <= out_d1;
        out_d3 <= out_d2;  
    end  
end
    
   
reg signed [OUTPUT_WIDTH-1:0] ask_demod;  
    
reg [31:0] ask_levels = 8;
reg signed [31:0] ask_bandwidth = (2**OUTPUT_WIDTH) / (ask_levels);





function [OUTPUT_WIDTH-1:0] abs (input signed [OUTPUT_WIDTH-1:0] a);
    abs = (a < 0) ? -a : a;
endfunction


wire d1_d2_match = abs(out_d1 - out_d2) <= ask_bandwidth;
wire d2_d3_match = abs(out_d3 - out_d2) <= ask_bandwidth;
wire d1_d3_match = abs(out_d1 - out_d3) <= ask_bandwidth;
    
always @(posedge clk) begin
//    if (out_valid) begin
//         if (d1_d2_match && d1_d3_match && d2_d3_match) ask_demod <= out_d1;
         if (d1_d2_match) ask_demod <= ask_bandwidth*((out_d1)/ask_bandwidth);
         if (d1_d3_match) ask_demod <= ask_bandwidth*((out_d1)/ask_bandwidth);
         if (d2_d3_match) ask_demod <= ask_bandwidth*((out_d3)/ask_bandwidth);
//    end
end    
    
    
    
    
endmodule
