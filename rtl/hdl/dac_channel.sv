
module dac_channel (

        
        input clk,
        input reset,
            
        input penable,
        input psel,
        input [31:0] paddr,
        input pwrite,
        input [31:0] pwdata,
        output [31:0] prdata,
        
        output [7:0] dac_data_out,
                
        input [7:0] ina_data,
        input [7:0] inb_data,
        input [7:0] ddsa_data,
        input [7:0] ddsb_data,
                        
        input [31:0] usb_rd_data,
        input usb_rd_data_valid,
        output usb_rd_full,
        
        output [1:0] att,
        output amp_en,
        output [2:0] led 
                                     
);


wire [1:0] stat_cfg;
wire [31:0] stat_limit;
wire [7:0] stat_min;
wire [7:0] stat_max;
wire [31:0] stat_count;    


wire [7:0] usb_data;


xpm_fifo_sync #(
    .USE_ADV_FEATURES("0000"),
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(65536),   // DECIMAL
    .READ_DATA_WIDTH(32),      // DECIMAL
    .WRITE_DATA_WIDTH(8)
)
fifo_inst (

    .rst(reset),       
    .wr_clk(clk),
    
    .din(usb_rd_data),      
    .wr_en(usb_rd_data_valid),
    .full(usb_rd_full),
    
    .dout(usb_data),  
    .rd_en(1)
);



wire [15:0] gain;  
wire [15:0] offset;  
wire [24:0] filter_cfg_din;
wire filter_cfg_ce;         
            
wire [2:0] mux; 
wire [31:0] raw;
      
          
wire [7:0] dac_data =   (mux == 0) ? raw :
                        (mux == 1) ? ina_data : 
                        (mux == 2) ? inb_data :
                        (mux == 3) ? ddsa_data : 
                        (mux == 4) ? ddsb_data : 
                        (mux == 5) ? usb_data : 
                        0; 
  
  
wire [7:0] dac_data_filtered;


fir_filter #( .LEN(21) ) 
fir_filter_inst (    
    .reset(reset),
    .clk(clk),

    .cfg_din(filter_cfg_din),
    .cfg_ce(filter_cfg_ce),
    
    .len(),    

    .in(signed'(dac_data)), 
    .valid_in(1),
    
    .out(dac_data_filtered),
    .valid_out()

);



gain_offset_clamp
#(
    .IN_WIDTH(8),
    .GAIN_WIDTH(16),
    .GAIN_RADIX(8),
    .OFFSET_WIDTH(8),
    .OUT_WIDTH(8)
)
dac_gain_offset (
    .clk(clk),
    .in(dac_data_filtered),
    .in_valid(1),
    .gain(gain),
    .offset(offset),
    .out(dac_data_out),
    .out_valid()
);


sigstat #( .WIDTH(8) )
sigstat_inst (

    .clk(clk),
        
    .reset(stat_cfg[0]),   
    .enable(stat_cfg[1]),
    
    .sig(dac_data_out),
    .sig_valid(1),
    .limit(stat_limit),
    .min(stat_min),
    .max(stat_max),
    .count(stat_count)    

);



dac_channel_regs regs (
    
    
    .clk(clk),
    .reset(reset),
    
    .penable(penable),
    .psel(psel),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata),
    
             
    .gain(gain),  
    .offset(offset),  
    .filter_cfg_din(filter_cfg_din),
    .filter_cfg_ce(filter_cfg_ce),          
               
    .mux(mux),
    
    .raw(raw),
    
    .stat_cfg(stat_cfg),
    .stat_limit(stat_limit),
    .stat_min(stat_min),
    .stat_max(stat_max),
    .stat_count(stat_count),
    
    .att(att),
    .amp_en(amp_en),
    .led(led)
    
);




endmodule
