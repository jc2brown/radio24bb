
module adc_channel(

    input clk,
    input reset,
            
    input penable,
    input psel,
    input [31:0] paddr,
    input pwrite,
    input [31:0] pwdata,
    output [31:0] prdata,            

    input [7:0] in,
    input valid_in,
    
    output reg [7:0] out,
    output reg valid_out,
    
    input dor_in,
    output dor_out, // stretched version of dor_in. Not sync'd to data out
            
    output [1:0] att,
    output amp_en,
    output [2:0] led 

);
    


wire[15:0] gain;
wire[7:0] offset;

wire[1:0] stat_cfg;
wire[31:0] stat_limit;
wire [31:0] stat_count;
wire [7:0] stat_min;
wire [7:0] stat_max;
    
    
wire [24:0] filter_cfg_din;
wire filter_cfg_ce;

    
reg [23:0] in_scaled;
reg in_scaled_valid;


wire [7:0] in_filtered;
wire in_filtered_valid;



reg [31:0] dor_count;

always @(posedge clk) begin
    if (reset) begin
        dor_count <= 0;
    end
    else begin
        if (dor_in) begin 
            dor_count <= 10000000;
        end
        else if (dor_count != 0) begin
            dor_count <= dor_count - 1;
        end
    end
end


assign dor_out = (dor_count != 0) ? 1'b1 : 1'b0;






sigstat #( .WIDTH(8) )
sigstat_inct (

    .clk(clk),
        
    .reset(stat_cfg[0]),   
    .enable(stat_cfg[1]),
    
    .sig(in),
    .sig_valid(valid_in),
    .limit(stat_limit),
    .min(stat_min),
    .max(stat_max),
    .count(stat_count)    

);


reg [7:0] in_offset;
always @(posedge clk) in_offset <= signed'(in) + signed'(offset); 

reg in_offset_valid;
always @(posedge clk) in_offset_valid <= valid_in; 






wire [7:0] in_clamped;

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
    .in(in),
    .in_valid(1),
    .gain(gain),
    .offset(offset),
    .out(in_clamped),
    .out_valid()
);

////always @(posedge clk) in_scaled <= (signed'(in) * signed'(gain)) + signed'({offset, 8'h0});
//always @(posedge clk) in_scaled <= (signed'(in_offset) * signed'(gain));
//always @(posedge clk) in_scaled_valid <= in_offset_valid;

//wire [7:0] in_clamped = 
//    signed'(in_scaled[23:8]) <= signed'(-128) ? -128 :
//         signed'(in_scaled[23:8]) >= signed'(127) ? 127 :
//              in_scaled[15:8];
              
              


  
fir_filter #( .LEN(21) ) 
fir_filter_inst (    
    .reset(reset),
    .clk(clk),

    .cfg_din(filter_cfg_din),
    .cfg_ce(filter_cfg_ce),
    
    .len(),    

    .in({{10{in_clamped[7]}}, in_clamped[7:0]}),
    .valid_in(in_scaled_valid),
    
    .out(in_filtered),
    .valid_out(in_filtered_valid)

);





wire [31:0] dout;
wire empty;

xpm_fifo_sync #(
    .USE_ADV_FEATURES("0000"),
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("auto"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(16),   // DECIMAL
    .READ_DATA_WIDTH(32),      // DECIMAL
    .WRITE_DATA_WIDTH(8)
)
fifo_inst (

    .rst(reset),       
    .wr_clk(clk),
    
    .din(in_filtered),      
    .wr_en(in_filtered_valid),
    
    .dout(dout),  
    .rd_en(1/*rd_en*/),
    .empty(empty)
);

//always @(posedge clk) out <= dout;
always @(posedge clk) out <= in_filtered;
//always @(posedge clk) valid_out <= !empty;
always @(posedge clk) valid_out <= in_filtered_valid;



   
   
   
   

adc_channel_regs regs (
    
    
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
