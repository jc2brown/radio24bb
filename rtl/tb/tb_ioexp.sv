`timescale 1ps / 1ps

module tb_ioexp(

    );
    
    
    
localparam NUM_IO = 7;  
    

reg clk = 1'b1;
always #5000 clk <= !clk;    

reg reset = 1'b1;
initial #100000 @(posedge clk) reset <= 1'b0;


reg [NUM_IO-1:0] in = 8'h00;
initial begin
    @(negedge reset);
    #100000 in <= 8'hA1;
    #10000000 in <= 8'hA2;
end    



wire sclk;
wire sdata;
wire le;


i2c_ioexp
#(
    .NUM_IO(NUM_IO),
    .CLK_DIV_BITS(8),
    .LE_WIDTH(1000),
    .INVERT_LE(1)
)
dut
(
    .clk(clk),
    .reset(reset),
    
    .in(in),
    
    .sclk(sclk),
    .sdata(sdata),
    .le(le)

);
        
    
    
    
    
    
    
    
    
    
    
    
endmodule
