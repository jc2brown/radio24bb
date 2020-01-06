

module dac_channel_regs (
    
    input clk,
    input reset,
        
    input penable,
    input psel,
    input [31:0] paddr,
    input pwrite,
    input [31:0] pwdata,
    output reg [31:0] prdata,
                             
                                             
    output reg [15:0] gain,  
    output reg [15:0] offset,  
    output reg [24:0] filter_cfg_din,
    output reg filter_cfg_ce,          
                          
    output reg [3:0] mux,    
    output reg [31:0] raw,
    
    output reg [1:0] stat_cfg,
    output reg [31:0] stat_limit,
    input [7:0] stat_min,
    input [7:0] stat_max,
    input [31:0] stat_count,
    
    output reg [1:0] att,
    output reg amp_en,
    output reg [2:0] led
    
    
);


localparam REG_GAIN         = 12'h00;
localparam REG_OFFSET       = 12'h04;
localparam REG_FILTER_COEF  = 12'h08;
localparam REG_MUX          = 12'h0C;

localparam REG_RAW          = 12'h10;
localparam REG_STAT_CFG     = 12'h14;
localparam REG_STAT_MIN     = 12'h18;
localparam REG_STAT_MAX     = 12'h1C;

localparam REG_STAT_LIMIT   = 12'h20;
localparam REG_STAT_COUNT   = 12'h24;
localparam REG_ATT          = 12'h28; 
localparam REG_AMP_EN       = 12'h2C;
 
localparam REG_LED          = 12'h30; 


always @(posedge clk)
begin
    if (reset) begin
                            
        gain <= 'h0;
        offset <= 'h0;
        filter_cfg_din <= 'h0;
        filter_cfg_ce <= 'h0;
        
        
        raw <= 'h0;       
        mux <= 'h0; 
        

        stat_cfg <= 'h1;
        stat_limit <= 'h0;

        att <= 2'b11;
        amp_en <= 1'b0;        
        led <= 3'b000;

        
                   
    end
    else begin
                
        filter_cfg_ce <= 'h0;
                
        
        if (penable && psel && pwrite) begin
            case ({paddr[11:2], 2'b00})
                            
                REG_GAIN: gain <= pwdata[15:0];     
                  
                REG_FILTER_COEF:
                    begin
                        filter_cfg_din <= pwdata[24:0];
                        filter_cfg_ce <= 1'b1;
                    end                        
                 
                    
                REG_RAW: raw <= pwdata;   
               
                REG_MUX: mux <= pwdata[3:0];   
                
                
                REG_STAT_CFG: stat_cfg <= pwdata[1:0];
                
                REG_STAT_LIMIT: stat_limit <= pwdata;

                REG_ATT: att <= pwdata[1:0];
                
                REG_AMP_EN: amp_en <= pwdata[0];
                
                REG_LED: led <= pwdata[2:0];


            endcase
        end
    end
end







always @(*)
begin
    prdata = 32'h0;

    case ({paddr[11:2], 2'b00})
            
        REG_STAT_MIN: prdata = stat_min;
        
        REG_STAT_MAX: prdata = stat_max;
        
        REG_STAT_COUNT: prdata = stat_count;    
                
        default: prdata = 32'h0;
    endcase
end





endmodule
