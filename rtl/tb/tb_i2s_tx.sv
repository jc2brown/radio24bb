`timescale 1ps / 1ps


module tb_i2s_tx(

    );



reg clk = 1;
always #5000 clk <= !clk;

reg reset = 1;
initial #50000 reset <= 1'b0;

/*
wire dout;

reg [15:0] in_l = 0;
reg [15:0] in_r = 1;
reg tx_valid = 0;
wire tx_full;


wire wclk;
wire bclk;
wire mclk;


i2s_ctrl ctrl (

    .clk(clk),
    .reset(reset),
    
    .mclk(mclk),
    .bclk(bclk),
    .wclk(wclk)

);




i2s_tx
#(
    .SAMPLE_DEPTH(16)
)    
tx
(
    .reset(reset),
    .mclk(mclk),
    .wclk(wclk),
    .bclk(bclk),
    .dout(dout),
    
    .in_l(in_l),
    .in_r(in_r),
    .valid(tx_valid),
    .full(tx_full)
    
    
);



always @(*) begin
    tx_valid <= !tx_full;
end


always @(posedge mclk) begin
    if (reset) begin
    end
    else begin
        if (!tx_full) begin
            in_l <= in_l + 2;
            in_r <= in_r + 2;
        end
    end
end






reg [15:0] out_l;
reg [15:0] out_r;

wire rx_valid;
wire rx_empty;

i2s_rx
#(
    .SAMPLE_DEPTH(16)
)    
rx
(
    .reset(reset),
    .mclk(mclk),
    .wclk(wclk),
    .bclk(bclk),
    .din(dout),
    
    .out_l(out_l),
    .out_r(out_r),
    .valid(rx_valid),
    .full(rx_empty)
    
    
);
*/



wire wclk;
wire bclk;
wire mclk;
wire dout;
wire din = dout;



i2s_ctrl ctrl (

    .clk(clk),
    .reset(reset),
    
    .mclk(mclk),
    .bclk(bclk),
    .wclk(wclk)

);



reg [15:0] tx_data_l = 0;
reg [15:0] tx_data_r = 1;
reg tx_data_valid;


always @(posedge wclk) begin
    if (reset) begin
        tx_data_valid <= 0;
    end
    else begin
        tx_data_l <= tx_data_l + 2;
        tx_data_r <= tx_data_r + 2;
        tx_data_valid <= 1;
    end
end




i2s_tx
#(
    .SAMPLE_DEPTH(16)
)    
tx
(
    .reset(reset),
    .mclk(clk),
    .wclk(wclk),
    .bclk(bclk),
    .dout(dout),
    
    .tx_data_l(tx_data_l),
    .tx_data_r(tx_data_r),
    .tx_data_valid(tx_data_valid)
    
    
);




wire [15:0] rx_data_l;
wire [15:0] rx_data_r;
wire rx_data_valid;





i2s_rx
#(
    .SAMPLE_DEPTH(16)
)    
rx
(
    .reset(reset),
    .mclk(clk),
    .wclk(wclk),
    .bclk(bclk),
    .din(din),
    
    .rx_data_l(rx_data_l),
    .rx_data_r(rx_data_r),
    .rx_data_valid(rx_data_valid)
    
);










endmodule







