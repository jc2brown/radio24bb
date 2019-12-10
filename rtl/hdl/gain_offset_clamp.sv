
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

reg signed [(IN_WIDTH+GAIN_WIDTH)-1:0] product_raw;

always @(posedge clk) product_raw <= (signed'(in) * signed'(gain)) + signed'({offset, {GAIN_RADIX{1'h0}}});
always @(posedge clk) out_valid <= in_valid;

//localparam signed [(IN_WIDTH+GAIN_WIDTH)-1:0] min = signed'({1'b1, {(OUT_WIDTH-1){1'b0}}, {GAIN_RADIX{1'b0}}});
//localparam signed [(IN_WIDTH+GAIN_WIDTH)-1:0] max = signed'({1'b0, {(OUT_WIDTH-1){1'b1}}, {GAIN_RADIX{1'b0}}});
localparam signed [(IN_WIDTH+GAIN_WIDTH-GAIN_RADIX)-1:0] min = signed'({1'b1, {(OUT_WIDTH-1){1'b0}}});
localparam signed [(IN_WIDTH+GAIN_WIDTH-GAIN_RADIX)-1:0] max = signed'({1'b0, {(OUT_WIDTH-1){1'b1}}});

wire signed [(IN_WIDTH+GAIN_WIDTH-GAIN_RADIX)-1:0] product = signed'(product_raw[(IN_WIDTH+GAIN_WIDTH)-1:GAIN_RADIX]);

wire signed [(IN_WIDTH+GAIN_WIDTH-GAIN_RADIX)-1:0] clamped_product = 
    product <= min ? min :
         product >= max ? max :
              product;
              
assign out = clamped_product[OUT_WIDTH-1:0];
              
endmodule