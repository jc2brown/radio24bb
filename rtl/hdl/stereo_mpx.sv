    
module stereo_mpx (

    input clk,
    input reset,
    
    input mclk,
    input mreset,
        
    input penable,
    input psel,
    input [31:0] paddr,
    input pwrite,
    input [31:0] pwdata,
    output [31:0] prdata,
    output pready,
        
    
    input signed [15:0] in_l,
    input signed [15:0] in_r,
    input in_valid,
    input in_valid_180,
    input mpx_sel,
    
    output reg signed [15:0] mpx_out,
    output reg mpx_valid
    
);
    
    

wire [7:0] dds_cfg;
wire dds_cfg_ce;    
wire [31:0] dds_step;

wire [15:0] pilot_gain;                               
wire signed [15:0] scaled_pilot;

wire signed [7:0] pilot;      




wire [1:0] stat_cfg;
wire [31:0] stat_limit;
wire [7:0] stat_min;
wire [7:0] stat_max;
wire [31:0] stat_count;    



 
reg signed [15:0] in;


always @(posedge mclk) begin
    if (mreset) begin
        in <= 0;
    end
    else begin    
        if (in_valid || in_valid_180) begin
            in <= (mpx_sel ? in_l : in_r);
        end
    end
end
   
 
 

always @(posedge mclk) begin
    if (mreset) begin
        mpx_out <= 0;
        mpx_valid <= 0;
    end
    else begin
        mpx_valid <= in_valid || in_valid_180;
        mpx_out <= scaled_pilot + in;
    end
end



                    
dds dds_inst (

    .clk(mclk),
    .reset(mreset),
    
    .cfg_clk(clk),
    .cfg_reset(reset),
    .cfg(dds_cfg),
    .cfg_ce(dds_cfg_ce), 
    
    .step(dds_step),    
    .fm_data(0),
    .pm_data(0),
    
    .out(pilot),
    .out_valid()

);


                        
gain_offset_clamp
#(
    .IN_WIDTH(8),
    .GAIN_WIDTH(24),
    .GAIN_RADIX(8),
    .OFFSET_WIDTH(16),
    .OUT_WIDTH(16)
)
am_modulator (
    .clk(mclk),
    .in(pilot),
    .in_valid(1),
    .gain(pilot_gain),
    .offset(0),
    .out(scaled_pilot),
    .out_valid()
);      




sigstat #( .WIDTH(8) )
sigstat_inst (

    .clk(mclk),
        
    .reset(stat_cfg[0]),   
    .enable(stat_cfg[1]),
    
    .sig(mpx_out[15:8]),
    .sig_valid(mpx_valid),
    .limit(stat_limit),
    .min(stat_min),
    .max(stat_max),
    .count(stat_count)    

);







mpx_regs regs_inst (
    
    .clk(clk),
    .reset(reset),
    
    
    
    .penable(penable),
    .psel(psel),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata), 
    
    
    .pilot_gain(pilot_gain),

    .rom_data(dds_cfg),
    .rom_wr_en(dds_cfg_ce),  
       
    .step(dds_step),
    
        
    .stat_cfg(stat_cfg),
    .stat_limit(stat_limit),
    .stat_min(stat_min),
    .stat_max(stat_max),
    .stat_count(stat_count)
          
        
);




    
endmodule
