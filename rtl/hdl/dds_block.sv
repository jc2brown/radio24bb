
module dds_block (
        
    input clk,
    input reset,
        
    input penable,
    input psel,
    input [31:0] paddr,
    input pwrite,
    input [31:0] pwdata,
    output [31:0] prdata,
    
    output signed [7:0] dds_data_out,
            
    input signed [7:0] ina_data,
    input signed [7:0] inb_data,
    input signed [7:0] ddsa_data,
    input signed [7:0] ddsb_data
                    
//    input [31:0] usb_rd_data,
//    input usb_rd_data_valid,
//    output usb_rd_full
                                             
);


wire [1:0] stat_cfg;
wire [31:0] stat_limit;
wire [7:0] stat_min;
wire [7:0] stat_max;
wire [31:0] stat_count;    


//wire signed [7:0] usb_data;


//xpm_fifo_sync #(
//    .USE_ADV_FEATURES("0000"),
//    .DOUT_RESET_VALUE("0"),    // String
//    .FIFO_MEMORY_TYPE("block"), // String
//    .FIFO_READ_LATENCY(1),     // DECIMAL
//    .FIFO_WRITE_DEPTH(65536),   // DECIMAL
//    .READ_DATA_WIDTH(32),      // DECIMAL
//    .WRITE_DATA_WIDTH(8)
//)
//fifo_inst (

//    .rst(reset),       
//    .wr_clk(clk),
    
//    .din(usb_rd_data),      
//    .wr_en(usb_rd_data_valid),
//    .full(usb_rd_full),
    
//    .dout(usb_data),  
//    .rd_en(1)
//);


wire [15:0] gain;  
wire [15:0] offset;  
wire [24:0] filter_cfg_din;
wire filter_cfg_ce;         
            
wire [2:0] mux; 
wire signed [31:0] raw;
 
wire [7:0] dds_cfg;
wire dds_cfg_ce;    
wire [31:0] dds_step;


wire signed [3:0] am_mux;
wire signed [31:0] am_raw;
wire signed [31:0] am_gain;
wire signed [31:0] am_offset;
      
wire signed [3:0] fm_mux;
wire signed [31:0] fm_raw;
wire signed [31:0] fm_gain;
wire signed [31:0] fm_offset;
      
wire signed [3:0] pm_mux;
wire signed [31:0] pm_raw;
wire signed [31:0] pm_gain;
wire signed [31:0] pm_offset;

    
wire signed [15:0] am_data = (am_mux == 0) ? am_raw :
                             (am_mux == 1) ? ina_data : 
                             (am_mux == 2) ? inb_data :
                             (am_mux == 3) ? ddsa_data :
                             (am_mux == 4) ? ddsb_data :
                             0;
                             
wire signed [15:0] fm_data = (fm_mux == 0) ? fm_raw :
                             (fm_mux == 1) ? ina_data : 
                             (fm_mux == 2) ? inb_data :
                             (fm_mux == 3) ? ddsa_data :
                             (fm_mux == 4) ? ddsb_data :
                             0;

wire signed [15:0] pm_data = (pm_mux == 0) ? pm_raw :
                             (pm_mux == 1) ? ina_data : 
                             (pm_mux == 2) ? inb_data :
                             (pm_mux == 3) ? ddsa_data :
                             (pm_mux == 4) ? ddsb_data :
                             0;
                                  
                                 
wire signed [23:0] scaled_am_data;

gain_offset_clamp
#(
    .IN_WIDTH(16),
    .GAIN_WIDTH(32),
    .GAIN_RADIX(8),
    .OFFSET_WIDTH(32),
    .OUT_WIDTH(32)
)
dds_am_gain_offset (
    .clk(clk),
    .in(am_data),
    .in_valid(1),
    .gain(am_gain),
    .offset(),
    .out(scaled_am_data),
    .out_valid()
);         
  
wire signed [23:0] scaled_fm_data;

gain_offset_clamp
#(
    .IN_WIDTH(16),
    .GAIN_WIDTH(32),
    .GAIN_RADIX(8),
    .OFFSET_WIDTH(32),
    .OUT_WIDTH(32)
)
dds_fm_gain_offset (
    .clk(clk),
    .in(fm_data),
    .in_valid(1),
    .gain(fm_gain),
    .offset(),
    .out(scaled_fm_data),
    .out_valid()
);
    
    
wire signed [23:0] scaled_pm_data;

gain_offset_clamp
#(
    .IN_WIDTH(16),
    .GAIN_WIDTH(32),
    .GAIN_RADIX(8),
    .OFFSET_WIDTH(32),
    .OUT_WIDTH(32)
)
dds_pm_gain_offset (
    .clk(clk),
    .in(pm_data),
    .in_valid(1),
    .gain(pm_gain),
    .offset(),
    .out(scaled_pm_data),
    .out_valid()
);

                
wire signed [7:0] dds_data;                
                    
dds dds_inst (

    .clk(clk),
    .reset(reset),
    
    .cfg(dds_cfg),
    .cfg_ce(dds_cfg_ce), 
    
    .step(dds_step),    
    .fm_data(scaled_fm_data),
    .pm_data(scaled_pm_data),
    
    .out(dds_data),
    .out_valid()

);


wire [7:0] prbs_data;
reg prbs_init;
always @(posedge clk) prbs_init <= reset;

prbs prbs_inst (
    .clk(clk),
    .reset(reset),
    .en(1'b1),
    .init(prbs_init),
    .data(prbs_data)
);
  
          
wire signed [15:0] prbs_gain;
wire signed [7:0] prbs_offset;
wire signed [7:0] scaled_prbs_data;

gain_offset_clamp
#(
    .IN_WIDTH(8),
    .GAIN_WIDTH(16),
    .GAIN_RADIX(8),
    .OFFSET_WIDTH(8),
    .OUT_WIDTH(8)
)
prbs_gain_offset (
    .clk(clk),
    .in(prbs_data),
    .in_valid(1),
    .gain(prbs_gain),
    .offset(prbs_offset),
    .out(scaled_prbs_data),
    .out_valid()
);


wire signed [7:0] dac_data = scaled_prbs_data + 
        mux == 0 ? raw :
        mux == 1 ? dds_data :
        mux == 2 ? ina_data : 
        mux == 3 ? inb_data : 
        0;
                               
                                               
wire signed [7:0] modulated_dac_data;
                        
gain_offset_clamp
#(
    .IN_WIDTH(8),
    .GAIN_WIDTH(16),
    .GAIN_RADIX(8),
    .OFFSET_WIDTH(8),
    .OUT_WIDTH(8)
)
am_modulator (
    .clk(clk),
    .in(dac_data),
    .in_valid(1),
    .gain(scaled_am_data),
    .offset(0),
    .out(modulated_dac_data),
    .out_valid()
);      
  
assign dds_data_out = modulated_dac_data; 
  

sigstat #( .WIDTH(8) )
sigstat_inst (

    .clk(clk),
        
    .reset(stat_cfg[0]),   
    .enable(stat_cfg[1]),
    
    .sig(dds_data_out),
    .sig_valid(1),
    .limit(stat_limit),
    .min(stat_min),
    .max(stat_max),
    .count(stat_count)    

);



dds_regs regs (
    
    .clk(clk),
    .reset(reset),
    
    .penable(penable),
    .psel(psel),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata), 
    
    
    .am_mux(am_mux),
    .am_raw(am_raw),
    .am_gain(am_gain),
    .am_offset(am_offset),    
        
    .fm_mux(fm_mux),
    .fm_raw(fm_raw),
    .fm_gain(fm_gain),
    .fm_offset(fm_offset), 

    .pm_mux(pm_mux),
    .pm_raw(pm_raw),
    .pm_gain(pm_gain),
    .pm_offset(pm_offset),       
               
    .mux(mux),    
    
    .raw(raw),
    
    .rom_data(dds_cfg),
    .rom_wr_en(dds_cfg_ce),  
       
    .step(dds_step),
    
    .prbs_gain(prbs_gain),
    .prbs_offset(prbs_offset),
        
    .stat_cfg(stat_cfg),
    .stat_limit(stat_limit),
    .stat_min(stat_min),
    .stat_max(stat_max),
    .stat_count(stat_count)
          
        
);




endmodule
