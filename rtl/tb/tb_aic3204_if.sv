`timescale 1ps / 1ps


module tb_aic3204_if();
    

reg clk = 1'b1;
always #5000 clk <= !clk;    

reg mclk = 1'b1;
always #10000 mclk <= !mclk;

reg reset = 1'b1;
initial #100000 @(posedge clk) reset <= 1'b0;


wire aic3204_mclk;
wire aic3204_wclk;
wire aic3204_bclk;
wire aic3204_din;
wire aic3204_dout;


/////////////////////////////////////////////
// PL interface
/////////////////////////////////////////////

wire [15:0] nw_fifo_rd_data;
wire nw_fifo_rd_valid;
wire nw_fifo_rd_en = 1'b1;
wire nw_fifo_empty;

wire [15:0] pw_fifo_rd_data;
wire pw_fifo_rd_valid;
wire pw_fifo_rd_en = 1'b1;
wire pw_fifo_empty;

wire [15:0] nw_fifo_wr_data = nw_fifo_rd_data;
wire nw_fifo_wr_en = nw_fifo_rd_valid;
wire nw_fifo_full;

wire [15:0] pw_fifo_wr_data = pw_fifo_rd_data;
wire pw_fifo_wr_en = pw_fifo_rd_valid;
wire pw_fifo_full;








/*

wire [31:0] out_l_uv;
wire [31:0] out_r_uv;

    
gen_tone
#(
    .AMPL(32767e-6),
    .FREQ(10e3),
    .VCM(0),
    .CM_NOISE_AMPL(0),
    .DM_NOISE_AMPL(0),
    .SAMPLE_RATE(480000)
)
gen_tone_out_l 
(
    .sig_p_uv(out_l_uv)
);


gen_tone
#(
    .AMPL(32767e-6),
    .FREQ(10e3),
    .VCM(0),
    .CM_NOISE_AMPL(0),
    .DM_NOISE_AMPL(0),
    .SAMPLE_RATE(480000)
)
gen_tone_out_r 
(
    .sig_p_uv(out_r_uv)
);

*/







    
    
    
    
aic3204_if aic3204_if_inst (
    
    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////

    .aic3204_mclk(aic3204_mclk),
    .aic3204_wclk(aic3204_wclk),
    .aic3204_bclk(aic3204_bclk),
    .aic3204_din(aic3204_din),
    .aic3204_dout(aic3204_dout),
    

    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////

    .clk(clk),
    .mclk(mclk),
    .reset(reset),
    
    .nw_fifo_rd_data(nw_fifo_rd_data),
    .nw_fifo_rd_valid(nw_fifo_rd_valid),
    .nw_fifo_rd_en(nw_fifo_rd_en),
    .nw_fifo_empty(nw_fifo_empty),
    
    
    .pw_fifo_rd_data(pw_fifo_rd_data),
    .pw_fifo_rd_valid(pw_fifo_rd_valid),
    .pw_fifo_rd_en(pw_fifo_rd_en),
    .pw_fifo_empty(pw_fifo_empty),
        
    .nw_fifo_wr_data(nw_fifo_wr_data),
    .nw_fifo_wr_en(nw_fifo_wr_en),
    .nw_fifo_full(nw_fifo_full),
    
    .pw_fifo_wr_data(pw_fifo_wr_data),
    .pw_fifo_wr_en(pw_fifo_wr_en),
    .pw_fifo_full(pw_fifo_full)

);
    
    
    
    
    

/////////////////////////////////////////////////////////////
//
// Signal generator
//
/////////////////////////////////////////////////////////////
    
    
wire [31:0] in_l_uv;
wire [31:0] in_r_uv;

    
gen_tone
#(
    .AMPL(0.4),
    .FREQ(10e3),
    .VCM(1.0),
    .CM_NOISE_AMPL(0.02),
    .DM_NOISE_AMPL(0.005),
    .SAMPLE_RATE(480000)
)
gen_tone_in_l 
(
    .sig_p_uv(in_l_uv)
);


gen_tone
#(
    .AMPL(0.4),
    .FREQ(10e3),
    .VCM(1.0),
    .CM_NOISE_AMPL(0.02),
    .DM_NOISE_AMPL(0.005),
    .SAMPLE_RATE(480000)
)
gen_tone_in_r 
(
    .sig_p_uv(in_r_uv)
);





wire [31:0] out_l_uv;
wire [31:0] out_r_uv;

    
aic3204 aic3204_inst
(
    .aic3204_mclk(aic3204_mclk),
    .aic3204_wclk(aic3204_wclk),
    .aic3204_bclk(aic3204_bclk),
    .aic3204_din(aic3204_din),
    .aic3204_dout(aic3204_dout),
    
    .in_l_uv(in_l_uv),
    .in_r_uv(in_r_uv),
    .out_l_uv(out_l_uv),
    .out_r_uv(out_r_uv)

);

   
   
always @(posedge clk) begin
    if (reset) begin
    
    end
    else begin
        
    end
end
   
    
endmodule
