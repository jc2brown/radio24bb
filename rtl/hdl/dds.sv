
module dds(

    input clk,
    input reset,
    
    input [7:0] cfg,
    input cfg_ce, 
    
    input [31:0] step,
    
    input [7:0] fm_in,
    input [23:0] fm_gain,
    input [23:0] fm_offset,
    
    output reg [31:0] out,
    output reg out_valid

);
    
    
    
          

reg [31:0] fm;
always @(posedge clk) fm <= (signed'(fm_in) * signed'(fm_gain)) + signed'({fm_offset, 8'h0});


/*
wire [29:0] dds_fm_in = 
signed'(result[23:8]) <= signed'(-128) ? -128 :
   signed'(result[23:8]) >= signed'(127) ? 127 :
        result[23:8];
        */
        
        
        
        
        
    

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
            accum <= signed'(accum) + signed'(step) + signed'(fm);
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
            out <= lut[accum[31:20]];
            out_valid <= 1'b1;
        end
        else begin
            out_valid <= 1'b0;
        end
    end
end




    
    
endmodule
