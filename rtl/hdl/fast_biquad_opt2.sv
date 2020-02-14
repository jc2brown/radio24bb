
module fast_biquad_opt2
#(
    parameter SAMPLE_WIDTH = 0,
    parameter COEF_WIDTH = 0
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
// Input registers
//
reg signed [SAMPLE_WIDTH-1:0] in_d0;
always @(posedge clk) in_d0 <= in;

reg in_valid_d0;
always @(posedge clk) in_valid_d0 <= in_valid;




//
// Feed-forward multipliers
//
wire signed [PRODUCT_WIDTH-1:0] b0_X_in_d0 = b0 * in_d0;
wire signed [PRODUCT_WIDTH-1:0] b1_X_in_d0 = b1 * in_d0;
wire signed [PRODUCT_WIDTH-1:0] b2_X_in_d0 = b2 * in_d0;



//
// Feed-forward post-multiplier registers
//
reg signed [PRODUCT_WIDTH-1:0] b0_X_in_d1;
always @(posedge clk) begin
    if (reset) begin
        b0_X_in_d1 <= 0;
    end
    else if (in_valid_d0) begin
        b0_X_in_d1 <= b0_X_in_d0;
    end
end


reg signed [PRODUCT_WIDTH-1:0] b1_X_in_d1;
always @(posedge clk) begin
    if (reset) begin
        b1_X_in_d1 <= 0;
    end
    else if (in_valid_d0) begin
        b1_X_in_d1 <= b1_X_in_d0;
    end
end


reg signed [PRODUCT_WIDTH-1:0] b2_X_in_d1;
always @(posedge clk) begin
    if (reset) begin
        b2_X_in_d1 <= 0;
    end
    else if (in_valid_d0) begin
        b2_X_in_d1 <= b2_X_in_d0;
    end
end


reg signed [PRODUCT_WIDTH-1:0] b2_X_in_d2;
always @(posedge clk) begin
    if (reset) begin
        b2_X_in_d2 <= 0;
    end
    else if (in_valid_d0) begin
        b2_X_in_d2 <= b2_X_in_d1;
    end
end




wire [PRODUCT_WIDTH-1:0] d1_term;
wire [PRODUCT_WIDTH-1:0] d2_terms;
wire [PRODUCT_WIDTH-1:0] d3_terms;
wire [PRODUCT_WIDTH-1:0] sum = d1_term + d2_terms + d3_terms;
wire [SAMPLE_WIDTH-1:0] out_d1 = sum[PRODUCT_WIDTH-4:PRODUCT_WIDTH-SAMPLE_WIDTH-3];





//
// Feedback multipliers
//
wire signed [PRODUCT_WIDTH-1:0] a1_X_out_d1 = a1 * out_d1;
wire signed [PRODUCT_WIDTH-1:0] a2_X_out_d1 = a2 * out_d1;





//
// Feedback post-multiplier registers
//
reg signed [PRODUCT_WIDTH-1:0] a1_X_out_d2;
always @(posedge clk) begin
    if (reset) begin
        a1_X_out_d2 <= 0;
    end
    else if (in_valid_d0) begin
        a1_X_out_d2 <= a1_X_out_d1;
    end
end


reg signed [PRODUCT_WIDTH-1:0] a2_X_out_d2;
always @(posedge clk) begin
    if (reset) begin
        a2_X_out_d2 <= 0;
    end
    else if (in_valid_d0) begin
        a2_X_out_d2 <= a2_X_out_d1;
    end
end















reg signed [SAMPLE_WIDTH-1:0] out_del [1:2];
//always @(*) out_del[1] <= sum;


reg valid_del [0:3];

//reg ready;



always @(posedge clk) begin
    if (reset) begin
        valid_del[0] <= 0;
        valid_del[1] <= 0;
        valid_del[2] <= 0;
        valid_del[3] <= 0;
        out_valid <= 0;
        out <= 0;
//        ready <= 0;
    end
    else begin
        valid_del[0] <= in_valid;
        valid_del[1] <= valid_del[0];
        valid_del[2] <= valid_del[1];
        valid_del[3] <= valid_del[2];
        out_valid <= valid_del[3];
        out <= out_del[1];
//        ready <= 1;
    end
end




reg signed [SAMPLE_WIDTH-1:0] in_del [0:2];

always @(posedge clk) begin
    if (reset) begin
        in_del[0] <= 0;
        in_del[1] <= 0;
        in_del[2] <= 0;
        in_del[3] <= 0;
    end
    else if (in_valid) begin
        in_del[0] <= in;
        in_del[1] <= in_del[0];
        in_del[2] <= in_del[1];
        in_del[3] <= in_del[2];
    end
end







always @(posedge clk) begin
    if (reset) begin
        out_del[2] <= 0;
//        out_del[3] <= 0;
    end
    else if (in_valid) begin
        out_del[2] <= out_del[1];
//        out_del[3] <= out_del[2];
    end
end





reg signed [PRODUCT_WIDTH-1:0] b0_in1;
always @(posedge clk) b0_in1 <= b0 * in_del[0];

reg signed [PRODUCT_WIDTH-1:0] b1_in2;
always @(posedge clk) b1_in2 <= b1 * in_del[1];

reg signed [PRODUCT_WIDTH-1:0] b2_in3;
always @(posedge clk) b2_in3 <= b2 * in_del[2];





reg signed [PRODUCT_WIDTH-1:0] a1_out2;
always @(posedge clk) begin
    if (reset) begin
        a1_out2 <= 0;
    end
    else begin
        a1_out2 <= a1 * out_del[1];
    end
end


reg signed [PRODUCT_WIDTH-1:0] a2_out3_p1;
always @(posedge clk) begin
    if (reset) begin
        a2_out3_p1 <= 0;
    end
    else begin
        a2_out3_p1 <= a2 * out_del[1];
    end
end

reg signed [PRODUCT_WIDTH-1:0] a2_out3;
always @(posedge clk) a2_out3 <= a2_out3_p1;







/*

wire signed [PRODUCT_WIDTH-1:0] sum = b0_in1 + b1_in2 + b2_in3 - a1_out2 - a2_out3; 

always @(*) begin
    out_del[1] <= sum[PRODUCT_WIDTH-4:PRODUCT_WIDTH-SAMPLE_WIDTH-3];
end

*/


endmodule








