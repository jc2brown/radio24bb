`timescale 1ps / 1ps


module tb_gain_offset_clamp(

    );
    

reg clk = 1'b1;
always #5000 clk <= !clk;    


reg reset = 1'b1;
initial #100000 @(posedge clk) reset <= 1'b0;


reg signed [7:0] fm_data;
wire [15:0] fm_gain = 512;
wire [7:0] scaled_fm_data;    
    
    
    
    
initial begin 

    while (1) begin
    
        reg signed [15:0] i;
        for (i=-1000;i<1000;i=i+1) begin
            @(posedge clk) begin
                fm_data <= i;
            end
        end
    
    end


end
    
    
    
gain_offset_clamp
#(
    .IN_WIDTH(8),
    .GAIN_WIDTH(16),
    .GAIN_RADIX(8),
    .OFFSET_WIDTH(8),
    .OUT_WIDTH(8)
)
dds_fm_gain_offset (
    .clk(clk),
    .in(fm_data),
    .in_valid(1),
    .gain(fm_gain),
    .offset(0),
    .out(scaled_fm_data),
    .out_valid()
);
     
    
    
    
    
endmodule
