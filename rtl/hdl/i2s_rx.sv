`timescale 1ps / 1ps



module i2s_rx
#(
    parameter SAMPLE_DEPTH = 16
)    
(
    input wire reset,
    input wire mclk,
    input wire wclk,
    input wire bclk,
    input wire din,
    
    output reg [15:0] rx_data_l,
    output reg [15:0] rx_data_r,
    output reg rx_data_valid
    
);





reg bclk_d1;
always @(posedge mclk) bclk_d1 <= bclk;

wire bclk_posedge = bclk && !bclk_d1;

wire bclk_negedge = !bclk && bclk_d1;


reg wclk_d1;
always @(posedge mclk) wclk_d1 <= wclk; 


reg wclk_posedge;
always @(posedge mclk) wclk_posedge <= wclk && !wclk_d1;

reg wclk_negedge;
always @(posedge mclk) wclk_negedge <= !wclk && wclk_d1;




reg peow;
reg neow;

always @(posedge mclk) begin
    if (wclk_negedge) begin
        peow <= 1;
    end
    if (wclk_posedge) begin
        neow <= 1;
    end
    if (bclk_posedge) begin
        peow <= 0;
        neow <= 0;
    end
end





reg [SAMPLE_DEPTH:0] pw = 'h0; // positive-wclk shift register 
reg [SAMPLE_DEPTH:0] nw = 'h0; // negative-wclk shift register 


always @(posedge mclk) begin
    if (bclk_posedge) begin
        pw <= {pw[SAMPLE_DEPTH-1:0], din};
        nw <= {nw[SAMPLE_DEPTH-1:0], din};
    end
end


reg [15:0] rx_data_l_tmp;

always @(posedge mclk) begin
    if (reset) begin
        rx_data_l_tmp <= 0;
    end
    else begin
        rx_data_valid <= 0;
        if (bclk_posedge) begin
            if (neow) begin
                rx_data_r <= {nw[SAMPLE_DEPTH-1:0], din};
                rx_data_l <= rx_data_l_tmp;
                rx_data_valid <= 1;
            end
            if (peow) begin
                rx_data_l_tmp <= {pw[SAMPLE_DEPTH-1:0], din};
            end
        end
    end
end

endmodule
