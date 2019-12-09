`timescale 1ps / 1ps

module tb_fm_demod(

    );
    
    
    


reg clk = 1;
always #5000 clk <= !clk; 

reg reset = 1;
initial #50000 @(posedge clk) reset <= 0;

reg run = 1;

reg [31:0] vco_gain = 400000;
reg [31:0] vco_bias = 400000000;

wire fin;
wire [31:0] fm;
wire [31:0] demod = fm - vco_bias;



wire [31:0] af_in_uv;
    
siggen
#(
    .AMPL(127e-6),
    .FREQ(10e3),
    .SAMPLE_RATE(100000000)
)
siggen_in_l 
(
    .sig_p_uv(af_in_uv)
);







//
// FM VCO
//
    
reg [31:0] accum;

always @(posedge clk) begin
    if (reset) begin
        accum <= 'h0;
    end
    else begin  
        if (run) begin
            accum <= signed'(accum) + signed'(vco_bias-0) + signed'(af_in_uv*1000000);
        end
    end
end
    
assign fin = accum[31];








fm_demod dut (

    .clk(clk),
    .reset(reset),
    
    .run(run),
    
    .vco_gain(vco_gain),
    .vco_bias(vco_bias),
    
    .fin(fin),
    .fm(fm)
    
);
    
    
    
    
endmodule
