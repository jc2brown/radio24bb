`timescale 1ps / 1ps

// Digital DAC
module ddac
#(
    parameter MODE = "DS", // "DS"=delta-sigma, "PWM"  
    parameter DEPTH = 8
)
(
    input wire clk,
    input wire [DEPTH-1:0] count,
    output reg out
);   
    
reg [DEPTH:0] accum = 0;
reg [DEPTH:0] avg = 0;

wire dac = (signed'(accum-avg) > 0);

always @(posedge clk) begin
    accum <= accum + count;    
    avg <= avg + dac * 2**DEPTH;
    out <= dac;
end

    
endmodule
