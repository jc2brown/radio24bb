
module dds (

    input clk,
    input reset,
    
    input [7:0] cfg,
    input cfg_ce, 
    
    input [31:0] step,
        
    input signed [31:0] fm_data,    
    input signed [11:0] pm_data,
    
    output reg signed [31:0] out,
    output reg signed out_valid

);
    


reg [7:0] dds_data;
reg dds_data_valid;
wire empty;

wire run = (step != 0);    

(* ram_style = "block" *)
reg [7:0] lut [0:4095];

reg [11:0] lut_addr;

always @(posedge clk) begin
    if (reset) begin
        lut_addr <= 'h0;
    end
    else begin
        if (cfg_ce) begin
            lut[lut_addr] <= cfg;
            lut_addr <= lut_addr + 1;
        end 
        else if (run) begin
            lut_addr <= 'h0;
        end
    end
end
    
    
    
reg [31:0] accum;
    
always @(posedge clk) begin
    if (reset) begin
        accum <= 'h0;
    end
    else begin  
        if (run) begin
            accum <= signed'(accum) + signed'(step) + signed'(fm_data);
        end
    end
end
    
    
always @(posedge clk) begin
    if (reset) begin
        out <= 'h0;
        out_valid <= 1'b0;
    end
    else begin
        if (run) begin        
            out <= lut[accum[31:20]+pm_data[11:0]];
            out_valid <= 1'b1;
        end
        else begin
            out_valid <= 1'b0;
        end
    end
end




    
    
endmodule
