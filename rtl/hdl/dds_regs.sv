

module dds_regs (
    
    input clk,
    input reset,
        
    input penable,
    input psel,
    input [31:0] paddr,
    input pwrite,
    input [31:0] pwdata,
    output reg [31:0] prdata,
    
    
    output reg [3:0] am_mux,
    output reg [31:0] am_raw,
    output reg [31:0] am_gain,
    output reg [31:0] am_offset,
     
    output reg [3:0] fm_mux,
    output reg [31:0] fm_raw,
    output reg [31:0] fm_gain,
    output reg [31:0] fm_offset,
        
    output reg [3:0] pm_mux,
    output reg [31:0] pm_raw,
    output reg [31:0] pm_gain,
    output reg [31:0] pm_offset,       
                                      
    output reg [3:0] mux,    
    
    output reg [31:0] raw,
               
    output reg [7:0] rom_data,
    output reg rom_wr_en,
    
    output reg [31:0] step, 
    
    output reg [15:0] prbs_gain,
    output reg [7:0] prbs_offset,                          
    
    output reg [1:0] stat_cfg,
    output reg [31:0] stat_limit,
    input [7:0] stat_min,
    input [7:0] stat_max,
    input [31:0] stat_count    
        
);



localparam REG_AM_MUX       = 12'h00;
localparam REG_AM_RAW       = 12'h04;
localparam REG_AM_GAIN      = 12'h08;
localparam REG_AM_OFFSET    = 12'h0C;

localparam REG_FM_MUX       = 12'h10;
localparam REG_FM_RAW       = 12'h14;
localparam REG_FM_GAIN      = 12'h18;
localparam REG_FM_OFFSET    = 12'h1C;

localparam REG_PM_MUX       = 12'h20;
localparam REG_PM_RAW       = 12'h24;
localparam REG_PM_GAIN      = 12'h28;
localparam REG_PM_OFFSET    = 12'h2C;

localparam REG_MUX          = 12'h30;
localparam REG_RAW          = 12'h34;

localparam REG_ROM          = 12'h38;

localparam REG_STEP         = 12'h3C;

localparam REG_PRBS_GAIN    = 12'h40;
localparam REG_PRBS_OFFSET  = 12'h44;

localparam REG_STAT_CFG     = 12'h48;
localparam REG_STAT_MIN     = 12'h4C;
localparam REG_STAT_MAX     = 12'h50;
localparam REG_STAT_LIMIT   = 12'h54;
localparam REG_STAT_COUNT   = 12'h58;



always @(posedge clk)
begin
    if (reset) begin
                                                    
        am_mux <= 'h0;
        am_raw <= 'h0;
        am_gain <= 'h0;
        am_offset <= 'h0;
            
        fm_mux <= 'h0;
        fm_raw <= 'h0;
        fm_gain <= 'h0;
        fm_offset <= 'h0;
        
        pm_mux <= 'h0;
        pm_raw <= 'h0;
        pm_gain <= 'h0;
        pm_offset <= 'h0;
                     
        raw <= 'h0;       
        
        mux <= 'h0; 
        
        rom_data <= 'h0;
        rom_wr_en <= 1'b0;
        
        step <= 'h0;
        
        prbs_gain <= 'h0;
        prbs_offset <= 'h0;

        stat_cfg <= 'h1;
        stat_limit <= 'h0;
                   
    end
    else begin
                
        rom_wr_en <= 1'b0;
                       
        if (penable && psel && pwrite) begin
            case ({paddr[11:2], 2'b00})                
                                          
                REG_AM_MUX:     am_mux <= pwdata[3:0];                         
                REG_AM_RAW:     am_raw <= pwdata;                   
                REG_AM_GAIN:    am_gain <= pwdata;                   
                REG_AM_OFFSET:  am_offset <= pwdata;     
                                                          
                REG_FM_MUX:     fm_mux <= pwdata[3:0];                         
                REG_FM_RAW:     fm_raw <= pwdata;                   
                REG_FM_GAIN:    fm_gain <= pwdata;                   
                REG_FM_OFFSET:  fm_offset <= pwdata;    
                                                          
                REG_PM_MUX:     pm_mux <= pwdata[3:0];                         
                REG_PM_RAW:     pm_raw <= pwdata;                   
                REG_PM_GAIN:    pm_gain <= pwdata;                   
                REG_PM_OFFSET:  pm_offset <= pwdata;                                  
                                                                                          
                REG_RAW: raw <= pwdata;   
               
                REG_MUX: mux <= pwdata[3:0];   
                
                REG_ROM: 
                    begin
                        rom_data <= pwdata[7:0];
                        rom_wr_en <= 1'b1;
                    end
               
                REG_STEP: step <= pwdata;   
                
                REG_PRBS_GAIN: prbs_gain <= pwdata[15:0];
                REG_PRBS_OFFSET: prbs_offset <= pwdata[7:0];
                
                REG_STAT_CFG: stat_cfg <= pwdata[1:0];                
                REG_STAT_LIMIT: stat_limit <= pwdata;

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
