
module gain_offset_clamp
#(
    parameter IN_WIDTH = 8,
    parameter GAIN_WIDTH = 16,
    parameter GAIN_RADIX = 8,
    parameter OFFSET_WIDTH = 8,
    parameter OUT_WIDTH = 8
)
(
    input clk,

    input in_valid,
    input signed [IN_WIDTH-1:0] in,
    input [GAIN_WIDTH-1:0] gain,
    input signed [OFFSET_WIDTH-1:0] offset,
    
    output reg out_valid,
    output signed [OUT_WIDTH-1:0] out
);



//
// STAGE 1
//

reg signed valid_d1;
always @(posedge clk) valid_d1 <= in_valid;

reg signed [IN_WIDTH-1:0] in_d1;
always @(posedge clk) in_d1 <= in;

reg signed [GAIN_WIDTH-1:0] gain_d1;
always @(posedge clk) gain_d1 <= gain;
    
reg signed [OFFSET_WIDTH-1:0] offset_d1;
always @(posedge clk) offset_d1 <= offset;
    

//
// STAGE 2
//

reg signed valid_d2;
always @(posedge clk) valid_d2 <= valid_d1;

reg signed [(IN_WIDTH+GAIN_WIDTH)-1:0] product_d2;
always @(posedge clk) product_d2 <= (signed'(in_d1) * signed'(gain_d1));

reg signed [OFFSET_WIDTH-1:0] offset_d2;
always @(posedge clk) offset_d2 <= offset_d1;


//
// STAGE 3
//

reg signed valid_d3;
always @(posedge clk) valid_d3 <= valid_d2;

reg signed [(IN_WIDTH+GAIN_WIDTH)-1:0] sum_d3;
always @(posedge clk) sum_d3 <= signed'(product_d2[(IN_WIDTH+GAIN_WIDTH)-1:GAIN_RADIX]) + signed'(offset_d2);


//
// STAGE 4
//

always @(posedge clk) out_valid <= valid_d3;


localparam signed [(IN_WIDTH+GAIN_WIDTH-GAIN_RADIX)-1:0] min = signed'({1'b1, {(OUT_WIDTH-1){1'b0}}});
localparam signed [(IN_WIDTH+GAIN_WIDTH-GAIN_RADIX)-1:0] max = signed'({1'b0, {(OUT_WIDTH-1){1'b1}}});

reg signed [(IN_WIDTH+GAIN_WIDTH-GAIN_RADIX)-1:0] clamped_sum;
always @(posedge clk)
    clamped_sum <= 
        (sum_d3 <= min) ? min :
             (sum_d3 >= max) ? max :
                  sum_d3;
                  
                
assign out = clamped_sum[OUT_WIDTH-1:0];
              
              
              
              
endmodule










