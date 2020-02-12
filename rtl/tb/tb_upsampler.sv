`timescale 1ps / 1ps



module tb_upsampler();
    
    
    
localparam INPUT_WIDTH = 8;
localparam OUTPUT_WIDTH = 16;

    
reg clk = 1'b1;
always #5000 clk <= !clk;  
    
   
reg reset = 1'b1;
initial #51000 reset <= 1'b0;
    
    
    
    
wire in_valid = !reset;

wire [OUTPUT_WIDTH-1:0] out;
wire out_valid;


    



        
wire signed [31:0] sig_p;

wire signed [INPUT_WIDTH-1:0] in = sig_p;
    
    
wire sigclk;
reg sigclk_d1;
always @(posedge clk) sigclk_d1 <= sigclk;
reg sigclk_d2;
always @(posedge clk) sigclk_d2 <= sigclk_d1;

wire sig_valid = sigclk_d1 && !sigclk_d2;


gen_tone
#(
    .AMPL(127e-6),
    .FREQ(8e3),
    .SAMPLE_RATE(38e3)
)
siggen_a 
(
    .sig_p_uv(sig_p),
    .clkout(sigclk)
);
    
    
    
    
    
localparam FS = 38e3;
localparam FSYS = 100e6;
    
wire [31:0] ratio = (2**24 * FS) / FSYS;


    
    
upsampler
#(
	.INPUT_WIDTH(INPUT_WIDTH),
    .OUTPUT_WIDTH(OUTPUT_WIDTH)
)
dut
(

    .clk(clk),
    .reset(reset),

    .in(in),
    .in_valid(sig_valid),
    
    .out(out),
    .out_valid(out_valid),
    
    .ratio(ratio) // input:output sample rate ratio, fixed-point Q0.24

);    
    
    
endmodule
