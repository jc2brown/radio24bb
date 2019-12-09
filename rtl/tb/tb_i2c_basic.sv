`timescale 1ps / 1ps

module tb_i2c_basic (

    );
    
    
    
    

reg clk = 1'b1;
always #5000 clk <= !clk;    

reg reset = 1'b1;
initial #1000000 @(posedge clk) reset <= 1'b0;

reg start = 1'b0;
wire done;

wire [7:0] data0_out;
wire [7:0] data1_out;

reg [1:0] num_wr_bytes;


reg [7:0] wr_data0 = 8'h00;
reg [7:0] wr_data1 = 8'h00;
reg [7:0] wr_data2 = 8'h00;

initial begin
    @(negedge reset);
    
    
//    #100000 in <= 8'hA1;
    #100000;    
    
    @(posedge clk) begin
        wr_data0 <= 8'hFF;
        wr_data1 <= 8'hF1;
        wr_data2 <= 8'h7E;
        num_wr_bytes <= 3;
        
         
    end
    @(posedge clk) start <= 1'b1;
    @(posedge clk) start <= 1'b0;
    
    
//    #100000000 in <= 8'hA2;
    
    
end    



wire sclk;
wire sdata;
wire sdata_oe_n;

i2c_basic
#(
    .CLK_DIV_BITS(8)
)
dut
(
    .clk(clk),
    .reset(reset),
    
    .addr(7'h41),   
    .num_wr_bytes(num_wr_bytes),
    .wr_data0(wr_data0),
    .wr_data1(wr_data1),
    .wr_data2(wr_data2),
    .start(start),
    .done(done),
    
    .sclk(sclk),
    .sdata_out(sdata),
    .sdata_oe_n(sdata_oe_n)
);
        
    
    
    
    
    
    
    
    
    
endmodule
