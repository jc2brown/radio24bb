`timescale 1ps / 1ps


module aic3204
#(
    parameter MCLK_FREQ = 96e6,
    parameter WCLK_FREQ = 96e3,
    parameter BCLK_FREQ = 3.84e6,
    

    parameter MCLK_DIV = 256,
    parameter SAMPLE_DEPTH = 16, // Sample-only
    parameter WORD_DEPTH = 16, // Sample+padding
    parameter MODE = "master", // "slave" not implemented
    parameter VREF = 1.0,
    parameter VCM = 1.0
)    
(

    input wire aic3204_mclk, // 50MHz in -> 195.3125KHz sample rate
    output reg aic3204_wclk, // 50MHz / 256 = 195.3125KHz
    output reg aic3204_bclk, // 50MHz / 16 = 31  195.3125KHz
    input wire aic3204_din,
    output reg aic3204_dout,
    
    input wire [31:0] in_l_uv,
    input wire [31:0] in_r_uv,
    output wire [31:0] out_l_uv,
    output wire [31:0] out_r_uv

);
   


//wire bit_launch_point;
//wire bit_sample_point;
   
   
localparam WCLK_DIV = MCLK_FREQ / WCLK_FREQ;
localparam BCLK_DIV = WCLK_DIV / (2 * WORD_DEPTH);


wire mclk = aic3204_mclk;

   

reg [31:0] mclk_div = 'h0;    

always @(posedge aic3204_mclk) begin
    mclk_div <= mclk_div + 1;
end    


// wclk = mclk / 256
wire wclk = mclk_div[7];
//assign aic3204_wclk = wclk;

// bclk = wclk*32 = mclk/8
wire bclk = mclk_div[2];        // 50MHz / 8 = 6.25MHz



// MSb goes to dout. 
// Width is 1 greater than SAMPLE_DEPTH to align dout with wclk
reg [SAMPLE_DEPTH:0] in_sr = 'h0; 





reg bclk_d1;
always @(posedge aic3204_mclk) bclk_d1 <= bclk;

wire bclk_posedge = bclk && !bclk_d1;

wire bclk_negedge = !bclk && bclk_d1;


reg wclk_d1;
always @(posedge mclk) wclk_d1 <= wclk; 


reg wclk_posedge;
always @(posedge mclk) wclk_posedge <= wclk && !wclk_d1;

reg wclk_negedge;
always @(posedge mclk) wclk_negedge <= !wclk && wclk_d1;

   



always @(posedge mclk) if (bclk_posedge || bclk_negedge) aic3204_bclk <= bclk;
always @(posedge mclk) if (bclk_posedge) aic3204_wclk <= wclk;
always @(posedge mclk) if (bclk_posedge) aic3204_dout <= in_sr[SAMPLE_DEPTH];





reg [SAMPLE_DEPTH-1:0] adc_l = 0;
reg [SAMPLE_DEPTH-1:0] adc_r = 0;
reg [SAMPLE_DEPTH-1:0] out_l = 0;
reg [SAMPLE_DEPTH-1:0] out_r = 0;


always @(posedge wclk) begin
//    adc_l <= (2**(SAMPLE_DEPTH-1)) * (in_l_uv - 1e6 * VCM) / (1e6 * VREF);
//    adc_r <= (2**(SAMPLE_DEPTH-1)) * (in_r_uv - 1e6 * VCM) / (1e6 * VREF);
    adc_l <= 16'h8000;
    adc_r <= 16'h8000;
end   




//always @(posedge mclk) begin
//    if (wclk_posedge && bit_launch_point) $error("ERROR: aic3204.sv: wclk_posedge collision");
//    if (wclk_negedge && bit_launch_point) $error("ERROR: aic3204.sv: wclk_negedge collision");
//    if (bit_sample_point && bit_launch_point) $error("ERROR: aic3204.sv: bit_sample_point collision");
//end




always @(posedge mclk) begin

    if (wclk_posedge) begin
        in_sr <= {in_sr[SAMPLE_DEPTH], adc_l};
    end
    else if (wclk_negedge) begin
        in_sr <= {in_sr[SAMPLE_DEPTH], adc_r};
    end
    else if (bclk_posedge) begin
        in_sr <= {in_sr[SAMPLE_DEPTH-1:0], 1'b0};
    end

end


    
reg [15:0] dac_l;
reg [15:0] dac_r;
    
    

reg [SAMPLE_DEPTH-1:0] out_sr = 'h0;
    
    
    
always @(posedge bclk) begin
    out_sr <= {out_sr[SAMPLE_DEPTH-2:0], aic3204_din};
end 
    
    
    
    
reg [15:0] pw = 'h0; // positive-wclk shift register 
reg [15:0] nw = 'h0; // negative-wclk shift register 

always @(posedge aic3204_mclk) begin
    if (bclk_posedge) begin
        if (!wclk) begin
            pw <= 16'h00;
        end
        else begin 
            pw <= {pw[14:0], aic3204_din};
        end
    end
end

always @(posedge aic3204_mclk) begin
    if (bclk_posedge) begin
        if (wclk) begin
            nw <= 16'h00;
        end
        else begin 
            nw <= {nw[14:0], aic3204_din};
        end
    end
end



always @(posedge aic3204_mclk) begin
    if (wclk_posedge) begin
        dac_r <= pw;
    end
    if (wclk_negedge) begin
        dac_l <= nw;
    end
end 
    
    
    
    
    
    
endmodule
