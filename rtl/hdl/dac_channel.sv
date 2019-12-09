
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
                        
        input [31:0] usb_rd_data,
        input usb_rd_data_valid,
        output usb_rd_full,
        
        output [1:0] att,
        output amp_en,
        output [2:0] led 
        
//        input [31:0] dds_fm,
//        input [31:0] dds_am
                                     
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
 
wire [7:0] dds_cfg;
wire dds_cfg_ce;    
wire [31:0] dds_step;


    
wire [7:0] dds_data;
    
    
wire [7:0] dds_fm_raw;
wire [2:0] dds_fm_mux;
    
wire [7:0] dds_fm = (dds_fm_mux == 0) ? dds_fm_raw :
                    (dds_fm_mux == 1) ? ina_data : 
                    (dds_fm_mux == 2) ? inb_data :
                    0;
     
     
wire [24:0] dds_fm_gain;           
wire [24:0] dds_fm_offset;           
                
                  
                    
dds dds_inst (

    .clk(clk),
    .reset(reset),
    
    .cfg(dds_cfg),
    .cfg_ce(dds_cfg_ce), 
    
    .step(dds_step),
    
    .fm_in(dds_fm),
    .fm_gain(dds_fm_gain),
    .fm_offset(dds_fm_offset),
    
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


          
wire [7:0] dac_data =   (mux == 0) ? raw :
                        (mux == 1) ? ina_data : 
                        (mux == 2) ? inb_data :
                        (mux == 3) ? usb_data : 
                        (mux == 4) ? dds_data : 
                        (mux == 5) ? prbs_data : 
                        0; 
  
/*  
wire [7:0] fm_raw;
wire [7:0] am_raw;
 
wire [2:0] am_mux;
wire [2:0] fm_mux;
  

wire [7:0] am_in  = (am_mux == 0) ? fm_raw :
                    (am_mux == 1) ? ina_data : 
                    (am_mux == 2) ? inb_data :
                    0;
  
                      

wire [7:0] fm_in  = (fm_mux == 0) ? fm_raw :
                    (fm_mux == 1) ? ina_data : 
                    (fm_mux == 2) ? inb_data :
                    0;
  
  
wire [7:0] fm_scaled;
  
  
clamped_mult_add 
cma_inst (
    .clk(clk),
    .in(fm_in),
    .gain(fm_gain),
    .offset(fm_offset),
    .out(fm_scaled)
);
*/


wire [7:0] modulated_dac_data = dac_data;
  /*


modulator modulator_inst (    
    .reset(reset),
    .clk(clk),

    .fm_in(fm_in),
    .am_in(am_in),
    
    .in(dac_data),
    .out(modulated_dac_data)
);

  
  
  
module clamped_mult_add
#(
    parameter IN_WIDTH = 8,
    parameter GAIN_WIDTH = 16
)
(

    input clk,
    input [7:0] in,
    input [15:0] gain,
    input [7:0] offset,
    output [7:0] out

);




reg [23:0] result;
always @(posedge clk) result <= (signed'(in) * signed'(gain)) + signed'({offset, 8'h0});



assign out = 
    signed'(result[23:8]) <= signed'(-128) ? -128 :
         signed'(result[23:8]) >= signed'(127) ? 127 :
              result[23:8];
              

endmodule  

              
              
       */       
              
  
  
  
  
  
  
wire [7:0] dac_data_filtered;


fir_filter #( .LEN(21) ) 
fir_filter_inst (    
    .reset(reset),
    .clk(clk),

    .cfg_din(filter_cfg_din),
    .cfg_ce(filter_cfg_ce),
    
    .len(),    

    .in({{10{modulated_dac_data[7]}}, modulated_dac_data[7:0]}),
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

//reg [23:0] dac_data_scaled;
//always @(posedge clk) dac_data_scaled <= (signed'(dac_data_filtered) * signed'(gain)) + signed'({offset, 8'h0});

//assign dac_data_out = 
//    signed'(dac_data_scaled[23:8]) <= signed'(-128) ? -128 :
//         signed'(dac_data_scaled[23:8]) >= signed'(127) ? 127 :
//              dac_data_scaled[23:8];
              
              
              
              
//assign dac_data_out =  dac_data_scaled[15:8];


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
    
    .dds_cfg(dds_cfg),
    .dds_cfg_ce(dds_cfg_ce),     
    .dds_step(dds_step),
        
    .stat_cfg(stat_cfg),
    .stat_limit(stat_limit),
    .stat_min(stat_min),
    .stat_max(stat_max),
    .stat_count(stat_count),
    
    .att(att),
    .amp_en(amp_en),
    .led(led),
    
    .dds_fm_mux(dds_fm_mux),
    .dds_fm_raw(dds_fm_raw),
    .dds_fm_gain(dds_fm_gain),
    .dds_fm_offset(dds_fm_offset)      
        
);




endmodule
