`timescale 1ps / 1ps


module aic3204
#(
    parameter MCLK_DIV = 256,
    parameter SAMPLE_DEPTH = 16,
    parameter MODE = "master", // "slave" not implemented
    parameter VREF = 1.0,
    parameter VCM = 1.0
)    
(

    input wire aic3204_mclk, // 50MHz in -> 195.3125KHz sample rate
    inout wire aic3204_wclk, // 50MHz / 256 = 195.3125KHz
    inout wire aic3204_bclk, // 50MHz / 16 = 31  195.3125KHz
    input wire aic3204_din,
    output wire aic3204_dout,
    
    input wire [31:0] in_l_uv,
    input wire [31:0] in_r_uv,
    output wire [31:0] out_l_uv,
    output wire [31:0] out_r_uv

);
   

reg [31:0] mclk_div = 'h0;    

always @(posedge aic3204_mclk) begin
    mclk_div <= mclk_div + 1;
end    


// wclk = mclk / 256
wire wclk = mclk_div[7];
assign aic3204_wclk = wclk;

// bclk = wclk*32 = mclk/8
wire bclk = mclk_div[2];        // 50MHz / 8 = 6.25MHz
assign aic3204_bclk = bclk;
assign aic3204_bclk = bclk;


reg [SAMPLE_DEPTH-1:0] adc_l;
reg [SAMPLE_DEPTH-1:0] adc_r;
reg [SAMPLE_DEPTH-1:0] out_l;
reg [SAMPLE_DEPTH-1:0] out_r;


always @(posedge wclk) begin
    adc_l <= (2**SAMPLE_DEPTH) * (in_l_uv - 1e6 * VCM) / (1e6 * VREF);
    adc_r <= (2**SAMPLE_DEPTH) * (in_r_uv - 1e6 * VCM) / (1e6 * VREF);
end   



reg [SAMPLE_DEPTH-1:0] in_sr = 'h0;


reg wclk_d1;
always @(posedge bclk) wclk_d1 <= wclk; 



always @(negedge bclk) begin
    if (wclk && !wclk_d1) begin
        in_sr <= adc_l;
    end
    else if (!wclk && wclk_d1) begin
        in_sr <= adc_r;
    end
    else begin    
        in_sr <= {1'b0, in_sr[SAMPLE_DEPTH-1:1]};
    end
end 
    
assign aic3204_dout = in_sr[0];
    
    
    
    
    
endmodule
