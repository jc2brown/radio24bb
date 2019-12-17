`timescale 1ps / 1ps



module i2c_rx
#(
    parameter SAMPLE_DEPTH = 16
)    
(
    input wire reset,
    input wire mclk,
    input wire wclk,
    input wire bclk,
    input wire din,
    
    output wire [15:0] out_l,
    output wire [15:0] out_r,
    output wire valid,
    input wire full
    
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







reg [15:0] pw = 'h0; // positive-wclk shift register 
reg [15:0] nw = 'h0; // negative-wclk shift register 

always @(posedge mclk) begin
    if (bclk_negedge) begin
        if (!wclk) begin
            pw <= 16'h00;
        end
        else begin 
            pw <= {pw[14:0], din};
        end
    end
end

always @(posedge mclk) begin
    if (bclk_negedge) begin
        if (wclk) begin
            nw <= 16'h00;
        end
        else begin 
            nw <= {nw[14:0], din};
        end
    end
end




endmodule
