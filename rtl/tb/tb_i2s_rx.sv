`timescale 1ps / 1ps



module tb_i2s_rx();
    
    
    


reg reset = 1;
initial #50000 reset <= 1'b0;



reg mclk = 1;
always #5000 mclk <= !mclk;

reg din = 0;

wire [15:0] out_l;
wire [15:0] out_r;
wire valid;
reg full = 0;



reg [31:0] mclk_div = 'h0;    

always @(posedge mclk) begin
    mclk_div <= mclk_div + 1;
end    

wire wclk = mclk_div[7];

// bclk = wclk*32 = mclk/8
wire bclk = !mclk_div[2];        // 50MHz / 8 = 6.25MHz


    
    
   
i2c_rx
#(
    .SAMPLE_DEPTH(16)
)    
dut
(
    .reset(reset),
    .mclk(mclk),
    .wclk(wclk),
    .bclk(bclk),
    .din(din),
    
    .out_l(out_l),
    .out_r(out_r),
    .valid(valid),
    .full(full)
    
    
);

    
    
initial begin


    @(negedge reset);
    @(posedge mclk);
    
    
    
    


end   
    
    
    
    
    
endmodule
