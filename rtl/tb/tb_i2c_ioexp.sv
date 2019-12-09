`timescale 1ps / 1ps

module tb_i2c_ioexp(

    );
    
    
    
    

reg clk = 1'b1;
always #5000 clk <= !clk;    

reg reset = 1'b1;
initial #1000000 @(posedge clk) reset <= 1'b0;


reg [15:0] in = 16'h00;
initial begin
    @(negedge reset);
    
    
//    #100000 in <= 8'hA1;
    #1000000 in <= 16'hFF00;
    
    
    #300000000 in <= 16'hAA55;
    
    
end    



wire sclk;
wire sdata;


i2c_ioexp
#(
    .CLK_DIV_BITS(8)
)
dut
(
    .clk(clk),
    .reset(reset),
    
    .in(in),
    
    .sclk(sclk),
    .sdata(sdata),
    .sdata_oe_n()
);
        
    
    
    
    
    
    
    
    
    
    
    
endmodule
