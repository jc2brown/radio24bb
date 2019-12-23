

module mpx_regs (
    
    input clk,
    input reset,
        
    input penable,
    input psel,
    input [31:0] paddr,
    input pwrite,
    input [31:0] pwdata,
    output reg [31:0] prdata,
    
    
    output reg [31:0] pilot_gain,
               
    output reg [7:0] rom_data,
    output reg rom_wr_en,
    
    output reg [31:0] step, 
                         
    
    output reg [1:0] stat_cfg,
    output reg [31:0] stat_limit,
    input [7:0] stat_min,
    input [7:0] stat_max,
    input [31:0] stat_count,    

    output reg [24:0] filter_cfg_din,
    output reg filter_cfg_ce        
        
);



localparam REG_PILOT_GAIN   = 12'h00;
localparam REG_ROM          = 12'h04;
localparam REG_STEP         = 12'h08;
localparam REG_STAT_CFG     = 12'h0C;

localparam REG_STAT_MIN     = 12'h10;
localparam REG_STAT_MAX     = 12'h14;
localparam REG_STAT_LIMIT   = 12'h18;
localparam REG_STAT_COUNT   = 12'h1C;

localparam REG_FILTER_COEF  = 12'h20;



always @(posedge clk)
begin
    if (reset) begin
                          
        pilot_gain <= 'h256; 
        
        rom_data <= 'h0;
        rom_wr_en <= 1'b0;
        
        step <= 'h0;

        stat_cfg <= 'h1;
        stat_limit <= 'h0;

        filter_cfg_din <= 'h0;
        filter_cfg_ce <= 'h0;
                   
    end
    else begin
                
        rom_wr_en <= 1'b0;
        filter_cfg_ce <= 'h0;
                       
        if (penable && psel && pwrite) begin
            case ({paddr[11:2], 2'b00})                
                                          
                REG_PILOT_GAIN:     pilot_gain <= pwdata;  
                
                REG_ROM: 
                    begin
                        rom_data <= pwdata[7:0];
                        rom_wr_en <= 1'b1;
                    end
               
                REG_STEP: step <= pwdata;   
                
                REG_STAT_CFG: stat_cfg <= pwdata[1:0];                
                REG_STAT_LIMIT: stat_limit <= pwdata;
                  
                REG_FILTER_COEF:
                    begin
                        filter_cfg_din <= pwdata[24:0];
                        filter_cfg_ce <= 1'b1;
                    end         
                    
            endcase
        end
    end
end



always @(*)
begin
    prdata = 32'h0;

    case ({paddr[11:2], 2'b00})
        
        REG_STAT_MIN:   prdata = stat_min;        
        REG_STAT_MAX:   prdata = stat_max;        
        REG_STAT_COUNT: prdata = stat_count;       
                     
        default: prdata = 32'h0;
        
    endcase
end





endmodule
