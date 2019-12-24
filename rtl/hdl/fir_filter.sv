
module fir_filter 
#(
    parameter LEN = 21,
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
    output valid_out

);
    
// Connect len to a CPU-accessible register so SW can find out how many taps it needs to load
assign len = LEN;
    
   
// n.b. these signal arrays are 1-indexed
wire valid [0:LEN];
assign valid[0] = valid_in;
assign valid_out = 1'b1;//valid[LEN];
reg [24:0] coef [0:LEN];
always @* coef[0] <= cfg_din;
reg [17:0] in_del [0:LEN];
always @* in_del[0] <= in; 
wire [47:0] result [0:LEN];
assign result[0] = 'h0;
//assign out = result[LEN][30:23];
         

assign out = 
    signed'(result[LEN][47:23]) <= LOWER ? LOWER :
    signed'(result[LEN][47:23]) >= UPPER ? UPPER :
    result[LEN][39:23];
   
    
    
// n.b. this generate block is 1-indexed
genvar i;
generate
for (i=1; i<=LEN; i=i+1) begin
    
    
    always @(posedge cfg_clk) begin
        if (cfg_reset) begin
            coef[i] = 32'h0080;
        end
        else if (cfg_ce) begin            
            coef[i] <= coef[i-1];
        end
    end
    
    always @(posedge cfg_clk) begin
        if (cfg_reset) begin
            in_del[i] = 0;
        end
        else begin            
            in_del[i] <= in_del[i-1];
        end
    end
        
    
    fir_cell fir_cell_inst (
    
        .clk(clk),
        .reset(reset),
        
        .valid_in(valid[i-1]),
        .valid_out(valid[i]),
        
        .mult_coef(coef[i]),
        .mult_in(in_del[i-1]),
        .acc_in(result[i-1]),
        .result(result[i])        
    
    );
    

end
endgenerate

    
endmodule
