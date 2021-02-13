
module fast_biquad_opt2
#(
    parameter SAMPLE_WIDTH = 0, // Up to 18bit for Zynq7000 DSP48
    parameter COEF_WIDTH = 0,    // Up to 30bit for Zynq7000 DSP48
    parameter COEF_INT_WIDTH = 0
)
(
    input clk,
    input reset,
    
    
    input signed [COEF_WIDTH-1:0] b0,
    input signed [COEF_WIDTH-1:0] b1,
    input signed [COEF_WIDTH-1:0] b2,
           
    input signed [COEF_WIDTH-1:0] a1,
    input signed [COEF_WIDTH-1:0] a2,
    

    input signed [SAMPLE_WIDTH-1:0] in,
    input in_valid,
    
    output reg signed [SAMPLE_WIDTH-1:0] out,
    output reg out_valid
    
);



localparam PRODUCT_WIDTH = SAMPLE_WIDTH + COEF_WIDTH;


//
// Output sum - predeclared here 
//
wire signed [PRODUCT_WIDTH-1:0] out_d1;

//
// Input registers
//
reg signed [SAMPLE_WIDTH-1:0] in_d0;
always @(posedge clk) in_d0 <= in;

reg valid_d0;
always @(posedge clk) valid_d0 <= in_valid;




//
// Feed-forward multipliers
//
wire signed [PRODUCT_WIDTH-1:0] b0_X_in_d0 = b0 * in_d0;
wire signed [PRODUCT_WIDTH-1:0] b1_X_in_d0 = b1 * in_d0;
wire signed [PRODUCT_WIDTH-1:0] b2_X_in_d0 = b2 * in_d0;



//
// Feed-forward post-multiplier registers
//

reg valid_d1;
always @(posedge clk) begin
    if (reset) begin
        valid_d1 <= 0;
    end
    else begin
        valid_d1 <= valid_d0;
    end
end


reg signed [PRODUCT_WIDTH-1:0] b0_X_in_d1;
always @(posedge clk) begin
    if (reset) begin
        b0_X_in_d1 <= 0;
    end
    else if (valid_d0) begin
        b0_X_in_d1 <= b0_X_in_d0;
    end
end


reg signed [PRODUCT_WIDTH-1:0] b1_X_in_d1;
always @(posedge clk) begin
    if (reset) begin
        b1_X_in_d1 <= 0;
    end
    else if (valid_d0) begin
        b1_X_in_d1 <= b1_X_in_d0;
    end
end


reg signed [PRODUCT_WIDTH-1:0] b2_X_in_d1;
always @(posedge clk) begin
    if (reset) begin
        b2_X_in_d1 <= 0;
    end
    else if (valid_d0) begin
        b2_X_in_d1 <= b2_X_in_d0;
    end
end


reg signed [PRODUCT_WIDTH-1:0] b2_X_in_d2;
always @(posedge clk) begin
    if (reset) begin
        b2_X_in_d2 <= 0;
    end
    else if (valid_d0) begin
        b2_X_in_d2 <= b2_X_in_d1;
    end
end
    
    




//
// Feedback multipliers
//
wire signed [PRODUCT_WIDTH-1:0] a1_X_out_d1 = -a1 * out_d1;
wire signed [PRODUCT_WIDTH-1:0] a2_X_out_d1 = -a2 * out_d1;




//
// Feedback post-multiplier registers
//

reg valid_d2;
always @(posedge clk) begin
    if (reset) begin
        valid_d2 <= 0;
    end
    else begin
        valid_d2 <= valid_d1;
    end
end


reg signed [PRODUCT_WIDTH-1:0] a2_X_out_d2;
always @(posedge clk) begin
    if (reset) begin
        a2_X_out_d2 <= 0;
    end
    else if (valid_d0) begin
        a2_X_out_d2 <= a2_X_out_d1;
    end
end


//
// Intermediate adders
//
wire signed [PRODUCT_WIDTH-1:0] sum1_d1 = b1_X_in_d1 - a1_X_out_d1;
wire signed [PRODUCT_WIDTH-1:0] sum2_d2 = b2_X_in_d2 - a2_X_out_d2;



//
// Post-intermediate adder registers
//

reg valid_d3;
always @(posedge clk) begin
    if (reset) begin
        valid_d3 <= 0;
    end
    else begin
        valid_d3 <= valid_d2;
    end
end


reg signed [PRODUCT_WIDTH-1:0] sum1_d2;
always @(posedge clk) begin
    if (reset) begin
        sum1_d2 <= 0;
    end
    else if (valid_d0) begin
        sum1_d2 <= sum1_d1;
    end
end


reg signed [PRODUCT_WIDTH-1:0] sum2_d3;
always @(posedge clk) begin
    if (reset) begin
        sum2_d3 <= 0;
    end
    else if (valid_d0) begin
        sum2_d3 <= sum2_d2;
    end
end



//
// Output adder
//
assign out_d1 = (b0_X_in_d1 / signed'(2**(COEF_WIDTH-COEF_INT_WIDTH))) + (sum1_d2 / signed'(2**(COEF_WIDTH-COEF_INT_WIDTH))) + (sum2_d3 / signed'((2**COEF_WIDTH-COEF_INT_WIDTH)));


//
// Output registers
//

always @(posedge clk) begin
    if (reset) begin
        out_valid <= 0;
    end
    else begin
        out_valid <= valid_d3;
        out_valid <= valid_d0;
    end
end


always @(posedge clk) begin
    if (reset) begin
        out <= 0;
    end
    else if (valid_d0) begin
        out <= out_d1;
    end
end





endmodule








