
module fast_biquad_opt
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









wire signed [PRODUCT_WIDTH-1:0] sum = b0_in1 + b1_in2 + b2_in3 - a1_out2 - a2_out3; 

always @(*) begin
    out_del[1] <= sum[PRODUCT_WIDTH-4:PRODUCT_WIDTH-SAMPLE_WIDTH-3];
end




endmodule



















/*


This uses per-register valid signals




module fast_biquad
#(
    parameter SAMPLE_WIDTH = 0,
    parameter COEF_WIDTH = 0
)
(
    input clk,
    input reset,
    
    
    input [COEF_WIDTH-1:0] b0,
    input [COEF_WIDTH-1:0] b1,
    input [COEF_WIDTH-1:0] b2,
    
    input [COEF_WIDTH-1:0] a1,
    input [COEF_WIDTH-1:0] a2,
    

    input [SAMPLE_WIDTH-1:0] in,
    input in_valid,
    
    output [SAMPLE_WIDTH-1:0] out,
    output reg out_valid
    
);


localparam PRODUCT_WIDTH = SAMPLE_WIDTH + COEF_WIDTH;


reg valid_del [0:1];

always @(posedge clk) begin
    if (reset) begin
        valid_del[0] <= 0;
        valid_del[1] <= 0;
        out_valid <= 0;
    end
    else begin
        valid_del[0] <= in_valid;
        valid_del[1] <= valid_del[0];
        out_valid <= valid_del[1];
    end
end




reg [SAMPLE_WIDTH-1:0] in_del [0:2];

always @(posedge clk) begin
    if (reset) begin
        in_del[0] <= 0;
        in_del[1] <= 0;
        in_del[2] <= 0;
        in_del[3] <= 0;
    end
    else begin
        in_del[0] <= in;
        in_del[1] <= in_del[0];
        in_del[2] <= in_del[1];
        in_del[3] <= in_del[2];
    end
end




reg [PRODUCT_WIDTH-1:0] b0_in1;
always @(posedge clk) b0_in1 <= b0 * in_del[1];

reg [PRODUCT_WIDTH-1:0] b1_in2;
always @(posedge clk) b1_in2 <= b1 * in_del[2];

reg [PRODUCT_WIDTH-1:0] b2_in3;
always @(posedge clk) b2_in3 <= b2 * in_del[3];



reg [PRODUCT_WIDTH-1:0] a1_out2;
always @(posedge clk) a1_out2 <= a1 * in_del[2];

reg [PRODUCT_WIDTH-1:0] a2_out3;
always @(posedge clk) a2_out3 <= a2 * in_del[3];






reg [SAMPLE_WIDTH-1:0] out_del [1:3];

wire [PRODUCT_WIDTH-1:0] sum = b0_in1 + b1_in2 + b2_in3 - a1_out2 - a2_out3; 

always @(*) begin
    out_del[1] <= sum[PRODUCT_WIDTH-1:PRODUCT_WIDTH-SAMPLE_WIDTH];
end


always @(posedge clk) begin
    if (reset) begin
        out_del[2] <= 0;
        out_del[3] <= 0;
    end
    else begin
        out_del[2] <= out_del[1];
        out_del[3] <= out_del[2];
    end
end







endmodule







*/