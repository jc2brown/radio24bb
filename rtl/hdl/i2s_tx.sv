`timescale 1ps / 1ps


module i2s_tx
#(
    parameter SAMPLE_DEPTH = 16
)    
(
    input wire reset,
    input wire mclk,
    input wire wclk,
    input wire bclk,
    output wire dout,
    
    input wire [15:0] tx_data_l,
    input wire [15:0] tx_data_r,
    input wire tx_data_valid
    
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

   

reg [15:0] in_l_reg;
reg in_l_full = 0;

reg [15:0] in_r_reg;
reg in_r_full = 0;


reg load_l = 0;
reg load_r = 0;

always @(posedge mclk) begin
    if (reset) begin
        in_l_full <= 1'b0;
        in_r_full <= 1'b0;
    end
    else begin
        if (load_l) begin  
            in_l_full <= 1'b0;
        end
        if (load_r) begin  
            in_r_full <= 1'b0;
        end
        if (tx_data_valid) begin
            in_l_reg <= tx_data_l;
            in_r_reg <= tx_data_r;
        end
    end
end



// MSb goes to dout. 
// Width is 1 greater than SAMPLE_DEPTH to align dout with wclk
reg [SAMPLE_DEPTH:0] in_sr = 'h0; 
assign dout = in_sr[SAMPLE_DEPTH];



always @(posedge mclk) begin

    load_l <= 1'b0;
    load_r <= 1'b0;
    
    if (wclk_posedge) begin
        in_sr <= {in_sr[SAMPLE_DEPTH], in_l_reg};
        load_l <= 1'b1;
    end
    else if (wclk_negedge) begin
        in_sr <= {in_sr[SAMPLE_DEPTH], in_r_reg};
        load_r <= 1'b1;
    end
    else if (bclk_posedge) begin
        in_sr <= {in_sr[SAMPLE_DEPTH-1:0], 1'b0};
    end

end


    
endmodule
