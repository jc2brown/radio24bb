
module fast_fir_filter 
#(
    parameter signed UPPER = 127,
    parameter signed LOWER = -128
)
(
    
    input reset,
    input clk,

    input cfg_clk,
    input cfg_reset,

    input [24:0] cfg_din,
    input cfg_ce,
    
    output [31:0] len,    

    input signed [17:0] in,
    input valid_in,
    
    output signed [17:0] out,
    output reg valid_out

);

genvar i;

localparam LEN = 21;
    
// Connect len to a CPU-accessible register so SW can find out how many taps it needs to load
assign len = LEN;
    
   
// n.b. these signal arrays are 1-indexed
reg valid_del [0:LEN];
always @* valid_del[0] <= valid_in;
//assign valid_out = 1'b1;
wire valid_out_del [0:LEN];
//assign valid_out = valid_out_del[LEN];
reg signed [24:0] coef [0:LEN];
always @* coef[0] <= cfg_din;
reg signed [17:0] in_del [0:LEN];
always @* in_del[0] <= in; 
wire signed [47:0] result [0:32];


for (i=LEN+1; i<=32; i=i+1) begin
    assign result[i] = 0;
end


assign result[0] = 'h0;
//assign out = result[LEN][30:23];
         

// assign out = 
//     signed'(result[LEN][47:23]) <= LOWER ? LOWER :
//     signed'(result[LEN][47:23]) >= UPPER ? UPPER :
//     signed'(result[LEN][39:23]);
       
reg signed [47:0] final_sum;

wire signed [27:0] output_sum = signed'(final_sum[47:19]); 
//wire signed [27:0] output_sum = signed'(final_sum[27:0]); 
       
assign out = 
    output_sum <= LOWER ? LOWER :
    output_sum >= UPPER ? UPPER :
    signed'(output_sum[16:0]);
    
    
    


// n.b. this generate block is 1-indexed
generate
for (i=1; i<=LEN; i=i+1) begin
    
    
    always @(posedge cfg_clk) begin
        if (cfg_reset) begin
            coef[i] <= 32'h0080;
        end
        else if (cfg_ce) begin            
            coef[i] <= coef[i-1];
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            in_del[i] <= 0;
            valid_del[i] <= 0;
        end
        else begin     
            valid_del[i] <= valid_del[i-1];       
            in_del[i] <= in_del[i-1];
        end
    end
        
    
    fast_fir_cell fast_fir_cell_inst (
    
        .clk(clk),
        .reset(reset),
        
        .valid_in(valid_del[i-1]),
        .valid_out(valid_out_del[i]),
        
        .mult_coef(coef[i]),
        .mult_in(in_del[i-1]),
        .result(result[i])        
    
    );
    

end
endgenerate



reg sum1_valid;
reg signed [47:0] sum1 [1:16];

reg sum2_valid;
reg signed [47:0] sum2 [1:8];

reg sum3_valid;
reg signed [47:0] sum3 [1:4];

reg sum4_valid;
reg signed [47:0] sum4 [1:2];



always @(posedge clk) sum1_valid <= valid_out_del[LEN];
always @(posedge clk) sum2_valid <= sum1_valid;
always @(posedge clk) sum3_valid <= sum2_valid;
always @(posedge clk) sum4_valid <= sum3_valid;
always @(posedge clk) valid_out <= sum4_valid;



generate
    
for (i=1; i<=16; i=i+1) begin    
    always @(posedge clk) begin
        if (valid_out_del[LEN]) begin
            sum1[i] <= result[2*i-1] + result[2*i];
        end
    end 
end

    
for (i=1; i<=8; i=i+1) begin    
    always @(posedge clk) begin
        if (sum1_valid) begin
            sum2[i] <= sum1[2*i-1] + sum1[2*i];
        end
    end 
end
    
for (i=1; i<=4; i=i+1) begin    
    always @(posedge clk) begin
        if (sum2_valid) begin
            sum3[i] <= sum2[2*i-1] + sum2[2*i];
        end
    end 
end
        
for (i=1; i<=2; i=i+1) begin    
    always @(posedge clk) begin
        if (sum3_valid) begin
            sum4[i] <= sum3[2*i-1] + sum3[2*i];
        end
    end 
end
endgenerate
    
    
always @(posedge clk) begin
    if (sum4_valid) begin
        final_sum <= sum4[1] + sum4[2];
    end
end 






    
endmodule
