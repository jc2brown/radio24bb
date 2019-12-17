`timescale 1ps / 1ps


module tb_r24bb();


reg clk = 1'b1;
always #5000 clk <= !clk;    
    
    

/////////////////////////////////////////////
// TCXO [2.5V] (1)
/////////////////////////////////////////////

wire tcxo_19M2;


/////////////////////////////////////////////
// FT601 Interface [2.5V] (39+1CC)
/////////////////////////////////////////////

wire ft601_clk;
wire [31:0] ft601_data;
wire [3:0] ft601_be;
wire ft601_rxf_n;
wire ft601_txe_n;
wire ft601_rd_n;
wire ft601_wr_n;
wire ft601_oe_n;
wire ft601_siwu_n;
wire ft601_reset_n;
wire ft601_wake_n;


/////////////////////////////////////////////
// MAX19506 interface [3.3V] (20+2CC)
/////////////////////////////////////////////

wire max19506_clkout_n;
wire max19506_clkout_p;

wire max19506_dclka;
wire [7:0] max19506_doa;
wire max19506_dora;

wire max19506_dclkb;
wire [7:0] max19506_dob;
wire max19506_dorb;


/////////////////////////////////////////////
// MAX5851 interface [3.3V] (19)
/////////////////////////////////////////////

wire max5851_clk_p;
wire max5851_clk_n;
wire max5851_clkin;

wire [7:0] max5851_dia;
wire [7:0] max5851_dib;

wire max5851_cw; 


/////////////////////////////////////////////
// AIC3204 interface [3.3V] (7+2CC)
/////////////////////////////////////////////

wire aic3204_mclk;
wire aic3204_wclk;
wire aic3204_bclk;
wire aic3204_din;
wire aic3204_dout;

wire line_in_det;
wire line_out_det;
wire phone_in_det;
wire phone_out_det;


    
    
    
    
    
    
    
    

/////////////////////////////////////////////////////////////
//
// ADC + signal generator
//
/////////////////////////////////////////////////////////////
    
    
wire [31:0] siga_p_uv;
wire [31:0] siga_n_uv;
    
gen_tone
#(
    .AMPL(0.4),
    .FREQ(10.7e6),
    .VCM(0.9),
    .CM_NOISE_AMPL(0.2),
    .DM_NOISE_AMPL(0.05)
)
gen_tone_a 
(
    .sig_p_uv(siga_p_uv),
    .sig_n_uv(siga_n_uv)
);
    
    
max19506 max19506_inst (
    .clk(clk),
    .ina_p_uv(siga_p_uv),
    .ina_n_uv(siga_n_uv),
    .doa(max19506_doa),
    .dora(max19506_dora),
    .dclka(max19506_dclka),
    .dob(max19506_dob),
    .dorb(max19506_dorb),
    .dclkb(max19506_dclkb)
);
    

    
    
    
    
/////////////////////////////////////////////////////////////
//
// USB
//
/////////////////////////////////////////////////////////////
    
ft601 ft601_inst (

    .reset_n(ft601_reset_n),

    .clk_out(ft601_clk),
    .data(ft601_data),    
    .oe_n(ft601_oe_n),
    .wr_n(ft601_wr_n),
    .rd_n(ft601_rd_n),
    .txe_n(ft601_txe_n),
    .rxf_n(ft601_rxf_n),
    .siwu_n(ft601_siwu_n)
    
);



    
    
    
    
    
    
    
r24bb_top top (


    /////////////////////////////////////////////
    // TCXO [2.5V] (1)
    /////////////////////////////////////////////
    
    .tcxo_19M2(tcxo_19M2), // multi-region clock-capable
    
    
    /////////////////////////////////////////////
    // FT601 Interface [2.5V] (39+1CC)
    /////////////////////////////////////////////
    
    .ft601_clk(ft601_clk),   // clock-capable
    .ft601_data(ft601_data),
    .ft601_be(ft601_be),
    .ft601_rxf_n(ft601_rxf_n),
    .ft601_txe_n(ft601_txe_n),
    .ft601_rd_n(ft601_rd_n),
    .ft601_wr_n(ft601_wr_n),
    .ft601_oe_n(ft601_oe_n),
    .ft601_siwu_n(ft601_siwu_n),
    .ft601_reset_n(ft601_reset_n),
    .ft601_wake_n(ft601_wake_n),  
    
    
    /////////////////////////////////////////////
    // MAX19506 interface [3.3V] (20+2CC)
    /////////////////////////////////////////////
    
    .max19506_clkout_n(max19506_clkout_n),
    .max19506_clkout_p(max19506_clkout_p),
    
    .max19506_dclka(max19506_dclka),    // clock-capable
    .max19506_doa(max19506_doa),
    .max19506_dora(max19506_dora),
    
    .max19506_dclkb(max19506_dclkb),    // clock-capable
    .max19506_dob(max19506_dob),
    .max19506_dorb(max19506_dorb),
    
    
    /////////////////////////////////////////////
    // MAX5851 interface [3.3V] (19)
    /////////////////////////////////////////////
    
    .max5851_clk_p(max5851_clk_p),
    .max5851_clk_n(max5851_clk_n),
    .max5851_clkin(max5851_clkin), // clock-capable
    
    .max5851_dia(max5851_dia),
    .max5851_dib(max5851_dib),
    
    .max5851_cw(max5851_cw), 


    /////////////////////////////////////////////
    // AIC3204 interface [3.3V] (7+2CC)
    /////////////////////////////////////////////

    .aic3204_mclk(aic3204_mclk),
    .aic3204_wclk(aic3204_wclk), // clock-capable
    .aic3204_bclk(aic3204_bclk), // clock-capable
    .aic3204_din(aic3204_din),
    .aic3204_dout(aic3204_dout),
    
    .line_in_det(line_in_det),
    .line_out_det(line_out_det),
    .phone_in_det(phone_in_det),
    .phone_out_det(phone_out_det)
    
);

    
    
    
    
    
    
    
    
    
endmodule
