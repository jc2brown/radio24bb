`timescale 1ps / 1ps


module tb_i2s_tx(

    );



reg reset = 1;
initial #50000 reset <= 1'b0;



reg mclk = 1;
always #5000 mclk <= !mclk;

wire dout;

reg [15:0] in_l;
reg [15:0] in_r;
reg valid;
wire full;



reg [31:0] mclk_div = 'h0;    

always @(posedge mclk) begin
    mclk_div <= mclk_div + 1;
end    

wire wclk = mclk_div[7];

// bclk = wclk*32 = mclk/8
wire bclk = !mclk_div[2];        // 50MHz / 8 = 6.25MHz






i2c_tx
#(
    .SAMPLE_DEPTH(16)
)    
dut
(
    .reset(reset),
    .mclk(mclk),
    .wclk(wclk),
    .bclk(bclk),
    .dout(dout),
    
    .in_l(in_l),
    .in_r(in_r),
    .valid(valid),
    .full(full)
    
    
);




always @(posedge mclk) begin
    in_l <= 16'h8000;
    in_r <= 16'h8000;
    valid <= !full;
end



endmodule


