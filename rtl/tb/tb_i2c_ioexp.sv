`timescale 1ps / 1ps

module tb_i2c_ioexp(

    );
    
    
    
    

reg clk = 1'b1;
always #5000 clk <= !clk;    

reg reset = 1'b1;
initial #1000000 @(posedge clk) reset <= 1'b0;


reg [15:0] in0 = 16'h00;
reg [15:0] in1 = 16'h00;
wire [15:0] out;
reg irq = 0;

initial begin
    @(negedge reset);
    
    
//    #100000 in <= 8'hA1;
    repeat (1000*1000) #10000;
    in0 <= 16'hFF00;
        
    repeat (1000*1000) #5000;
    in1 <= 16'hAA55;
    
    repeat (1000*1000) #5000;
    in0 <= 16'hAA55;
    
    repeat (1000*1000) #5000;
    irq <= 1;
end    



wire sclk;
wire sdata_out;



















i2c_ioexp
#(
    .CLK_DIV_BITS(10),
    .USE_IN0(1),
    .USE_IN1(1),
    .INPUTS0(16'h02),
    .INPUTS1(16'h00),
    .USE_IOBUF(0)     
)
dut
(

    .clk(clk),
    .reset(reset),
    
    .in(in0),
    .out0(out),
    .irq0(irq),
    
    .in1(in1),
    .out1(),
    .irq1(0),
    
    .sclk(sclk),
    .sdata(sdata_out),
    .sdata_in(1),
    .sdata_oe_n()
    

    
);












    
    
    
    
    
    
    
    
endmodule
