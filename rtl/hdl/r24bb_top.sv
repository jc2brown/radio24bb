`timescale 1ps / 1ps


module r24bb_top(


    /////////////////////////////////////////////
    // TCXO [2.5V] (1)
    /////////////////////////////////////////////
    
    input wire TCXO_19M2, // multi-region clock-capable
        
    
    /////////////////////////////////////////////
    // FT601 Interface [2.5V] (39+1CC)
    /////////////////////////////////////////////
        
    input USB_CLK,      // multi-region clock-capable
    inout [31:0] USB_D,
    inout [3:0] USB_BE,
        
    input USB_TXE_N,
    input USB_RXF_N,
    output USB_RD_N,
    output USB_WR_N,
    output USB_OE_N,
    output USB_SIWU_N,
        
    output USB_IO_CLK,
    inout USB_IO_DATA,
    input USB_IO_INT_N,
        
    
    /////////////////////////////////////////////
    // MAX19506 interface [3.3V] (20+2CC)
    /////////////////////////////////////////////
    
    output ADC_CLK_P,
    output ADC_CLK_N,

    input ADC_DORA,
    input [7:0] ADC_DA,
    input ADC_DCLKA,
    
    input ADC_DORB,
    input [7:0] ADC_DB,
    input ADC_DCLKB,
    
    output ADC_SDIN,
    output ADC_SCLK,
    output ADC_CSN,
    
    output ADC_IO_CLK,
    output ADC_IO_DATA,
    
    
    /////////////////////////////////////////////
    // MAX5851 interface [3.3V] (19)
    /////////////////////////////////////////////
            
    output DAC_CLKX_P,
    output DAC_CLKX_N,
    output DAC_CLK,
    
    output DAC_CWN,
            
    output [7:0] DAC_DA,    
    output [7:0] DAC_DB,
    
    output DAC_IO_CLK,
    output DAC_IO_DATA,    


    /////////////////////////////////////////////
    // AIC3204 interface [3.3V] (7+2CC)
    /////////////////////////////////////////////
    
    output CODEC_MCLK,
    output CODEC_BCLK,
    output CODEC_WCLK,
    output CODEC_DIN,
    input CODEC_DOUT,
    
    output CODEC_IO_CLK,
    output CODEC_IO_DATA,
    output CODEC_IO_INT_N,



    /////////////////////////////////////////////
    // External device GPIO
    /////////////////////////////////////////////
        
    inout EXT_GPIO0,
    inout EXT_GPIO1,

    output LED0,
    output LED1

);


wire pl_clk0;
wire pl_reset_n;


wire [31:0] ina_prdata;
wire [31:0] inb_prdata;
wire [31:0] outa_prdata;
wire [31:0] outb_prdata;
wire [31:0] regs_prdata;
wire [31:0] mpx_prdata;



wire [63:0] GPIO_0_0_tri_i;
wire [63:0] GPIO_0_0_tri_o;
wire [63:0] GPIO_0_0_tri_t;


/////////////////////////////////////////////////////////////
//
// Registers
//
/////////////////////////////////////////////////////////////
      
wire penable;
wire psel;
wire [31:0] paddr;
wire pwrite;
wire [31:0] pwdata;
wire [31:0] prdata;


wire [1:0] usb_wr_mux;    
    
wire [7:0] dac_cfg;
wire dac_cfg_wr_en;



/////////////////////////////////////////////////////////////
//
// USB
//
/////////////////////////////////////////////////////////////

wire [31:0] usb_wr_data;    
wire [31:0] usb_wr_data_raw;    
wire [3:0] usb_wr_be;  
wire [3:0] usb_wr_be_raw;  
wire usb_wr_en;
wire usb_wr_en_raw;
wire usb_wr_fifo_full;

wire [31:0] usb_rd_data;
wire [3:0] usb_rd_be;
wire usb_rd_en;
wire usb_rd_valid;
wire usb_rd_fifo_empty;



/////////////////////////////////////////////////////////////
//
// AUDIO
//
/////////////////////////////////////////////////////////////

wire signed [15:0] aud_in_l;
wire signed [15:0] aud_in_r;
wire signed [15:0] aud_in = aud_in_l + aud_in_r;
wire rx_data_valid;
wire rx_data_valid_180;



/////////////////////////////////////////////////////////////
//
// Stereo MPX
//
/////////////////////////////////////////////////////////////

(* async_reg = "true" *)
reg signed [15:0] mpx;



/////////////////////////////////////////////////////////////
//
// DDS
//
/////////////////////////////////////////////////////////////

wire signed [7:0] ddsa_data;
wire signed [7:0] ddsb_data;





/////////////////////////////////////////////////////////////
//
// DAC/ADC clock generator
//
/////////////////////////////////////////////////////////////

//wire clkout0;
//wire clkout1;
//wire clkout2;

wire adc_dclk = pl_clk0;
wire dac_dclk = pl_clk0;
wire mclk;

wire clkfb;
wire locked;

wire clk = pl_clk0;
wire reset = !pl_reset_n;

/*
MMCME2_BASE #(
    //.CLKIN1_PERIOD(52.083), // 19.2MHz 
    .CLKIN1_PERIOD(10.000), // 100MHz 
    .BANDWIDTH("LOW"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
    .CLKFBOUT_MULT_F(10.0), // 100MHz in -> 1000MHz VCO  
    .CLKOUT0_DIVIDE_F(12.5),    // 1000MHz VCO -> 80MHz DAC clk 
    .CLKOUT1_DIVIDE(10),     // 1000MHz VCO -> 100MHz ADC clk
    .CLKOUT2_DIVIDE(20)     // 1000MHz VCO -> 50MHz MCLK clk
)
MMCME2_BASE_inst (
//    .CLKIN1(TCXO_19M2), 
    .CLKIN1(clk), 
    .CLKFBOUT(clkfb),  
    .CLKFBIN(clkfb),    
    .CLKOUT0(clkout0),   
    .CLKOUT1(clkout1),   
    .CLKOUT2(clkout2),   
    .LOCKED(locked), 
    .PWRDWN(1'b0),     
    .RST(1'b0)      
);
*/


MMCME2_BASE #(
    .REF_JITTER1(0.01), // 0.01UI = 100ps
    .CLKIN1_PERIOD(10.000), // 100MHz 
    .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)  
    .DIVCLK_DIVIDE(6),
    .CLKFBOUT_MULT_F(51.875), // 100MHz in -> 864.583MHz VCO
    .CLKOUT0_DIVIDE_F(88.875)    // 864.583MHz VCO -> 9.728MHz MCLK 
)
MMCME2_BASE_inst (
//    .CLKIN1(TCXO_19M2), 
    .CLKIN1(clk), 
    .CLKFBOUT(clkfb),  
    .CLKFBIN(clkfb),    
    .CLKOUT0(mclk),     
    .LOCKED(locked), 
    .PWRDWN(1'b0),     
    .RST(1'b0)      
);


/*
assign clk <= clkout0;
assign mclk <= clkout1; 
MMCME2_BASE #(
    .CLKIN1_PERIOD(52.083), // 19.2MHz 
    .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
    .CLKFBOUT_MULT_F(38.0), // 19.2MHz in -> 729.6MHz VCO  
    .CLKOUT0_DIVIDE_F(7.5),    // 729.6MHz VCO -> 97.28MHz DAC/ADC clk 
    .CLKOUT1_DIVIDE(75)     // 1000MHz VCO -> 9.728MHz MCLK clk
)
MMCME2_BASE_inst (
//    .CLKIN1(TCXO_19M2), 
    .CLKIN1(clk), 
    .CLKFBOUT(clkfb),  
    .CLKFBIN(clkfb),    
    .CLKOUT0(clkout0),   
    .CLKOUT1(clkout1),   
    .LOCKED(locked), 
    .PWRDWN(1'b0),     
    .RST(1'b0)      
);
*/


/////////////////////////////////////////////////////////////
//
// MAX19506 ADC
// 100MHz 2x8bit 1.6Gb/s
//
/////////////////////////////////////////////////////////////


wire [7:0] adc_a_data;
wire adc_a_dor;
wire adc_a_rden;
wire adc_a_empty;

wire [7:0] adc_b_data;
wire adc_b_dor;
wire adc_b_rden;
wire adc_b_empty;

wire dora;
wire dorb;

assign GPIO_0_0_tri_i[7] = dora;
assign GPIO_0_0_tri_i[3] = dorb;


wire [1:0] ina_att;
wire ina_amp_en;
wire [2:0] ina_led;    
    
wire [1:0] inb_att;
wire inb_amp_en;
wire [2:0] inb_led;    

wire INA_LED_COM = 1'b0;
wire INB_LED_COM = 1'b0;


// Force red LEDs on data overranges
wire [15:0] adc_io = {
    // Port 1 [7:0]
    INB_LED_COM,
    !(dora ? 1 : ina_led[2]),
    !(dorb ? 1 : inb_led[2]),
    INB_LED_COM,
    !(dorb ? 0 : inb_led[1]),
    !(dorb ? 0 : inb_led[0]),
    !(dora ? 0 : ina_led[1]),
    !(dora ? 0 : ina_led[0]),
    // Port 0 [7:0]
    1'b0,
    ina_amp_en,
    !ina_att[1],
    !ina_att[0],
    1'b0,
    inb_amp_en,
    !inb_att[1],
    !inb_att[0]
};


max19506_serial_if max19506_serial_if_inst (

    .clk(clk),
    .reset(reset),
    
    .max19506_sclk(ADC_SCLK),
    .max19506_sdin(ADC_SDIN),
    .max19506_spen(ADC_CSN),
        
    .shdn(1'b0)
);



wire ADC_IO_CLK_n;
wire ADC_IO_DATA_n;

assign ADC_IO_CLK = !ADC_IO_CLK_n;
assign ADC_IO_DATA = !ADC_IO_DATA_n;

i2c_ioexp adc_i2c_ioexp (

    .clk(clk),
    .reset(reset),
    
    .in(adc_io),
    
    .sclk(ADC_IO_CLK_n),
    .sdata(ADC_IO_DATA_n),
    .sdata_oe_n()

);



max19506_if max19506_if_inst (
    
    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////
       
    
    .max19506_clkout_n(ADC_CLK_N),
    .max19506_clkout_p(ADC_CLK_P),

    .max19506_dclka(ADC_DCLKA),
    .max19506_doa(ADC_DA),
    .max19506_dora(ADC_DORA),
    
    .max19506_dclkb(ADC_DCLKB),
    .max19506_dob(ADC_DB),
    .max19506_dorb(ADC_DORB),
    
    
    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////

    .clk(clk),
    .reset(reset),
    
    .adc_dclk(adc_dclk),
    
    .adc_a_data(adc_a_data),
    .adc_a_dor(adc_a_dor),
    .adc_a_rden(1'b1),    
    .adc_a_empty(adc_a_empty),  
        
    .adc_b_data(adc_b_data),
    .adc_b_dor(adc_b_dor),
    .adc_b_rden(1'b1),
    .adc_b_empty(adc_b_empty)
        
);



wire [7:0] ina_data;
//wire ina_valid;


adc_channel ina_adc_channel (

    .clk(clk),
    .reset(reset),
              
    .penable(penable),
    .psel(paddr[31:12] == 20'h43C00),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(ina_prdata),
    
    .in(adc_a_data),
    .valid_in(1),
    
    .out(ina_data),
    .valid_out(),
    
    .dor_in(adc_a_dor),
    .dor_out(dora),
                        
    .att(ina_att),
    .amp_en(ina_amp_en),
    .led(ina_led) 
    

);
    
    
wire [7:0] inb_data;
//wire inb_valid;


adc_channel #(.FAST_FIR("false")) inb_adc_channel (

    .clk(clk),
    .reset(reset),
          
    .penable(penable),
    .psel(paddr[31:12] == 20'h43C01),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(inb_prdata),            
    
    .in(adc_b_data),
    .valid_in(1),
    
    .out(inb_data),
    .valid_out(),
        
    .dor_in(adc_b_dor),
    .dor_out(dorb),
                                
    .att(inb_att),
    .amp_en(inb_amp_en),
    .led(inb_led) 
    
);
    
       

/////////////////////////////////////////////////////////////
//
// MAX5851 DAC
// 80MHz 2x8bit 1.28Gb/s
//
/////////////////////////////////////////////////////////////


wire [1:0] outa_att;
wire outa_amp_en;
wire [2:0] outa_led;    
    
wire [1:0] outb_att;
wire outb_amp_en;
wire [2:0] outb_led;    

wire dac_dce; 

wire OUTA_LED_COM = 1'b0;
wire OUTB_LED_COM = 1'b0;

wire [15:0] dac_io = 
{
    // Port 1 [7:0]
    !outa_led[2],
    OUTB_LED_COM,
    !outb_led[2],
    OUTA_LED_COM,
    !outa_led[1],
    !outa_led[0],
    !outb_led[0],
    !outb_led[1],
    // Port 0 [7:0]
    !outb_att[0],
    !outb_att[1],
    outb_amp_en,
    1'b0,
    !dac_dce,
    !outa_att[0],
    !outa_att[1],
    outa_amp_en
};


wire DAC_IO_CLK_n;
wire DAC_IO_DATA_n;

assign DAC_IO_CLK = !DAC_IO_CLK_n;
assign DAC_IO_DATA = !DAC_IO_DATA_n;

i2c_ioexp dac_i2c_ioexp (

    .clk(clk),
    .reset(reset),
    
    .in(dac_io),
    
    .sclk(DAC_IO_CLK_n),
    .sdata(DAC_IO_DATA_n),
    .sdata_oe_n()

);

    
wire [7:0] outa_data_out;
wire outa_usb_rd_full;

    
dac_channel outa_dac_channel (

        
        .clk(clk),
        .reset(reset),
            
        .penable(penable),
        .psel(paddr[31:12] == 20'h43C02),
        .paddr(paddr),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .prdata(outa_prdata),
        
        .dac_data_out(outa_data_out),
                
        .ina_data(ina_data),        
        .inb_data(inb_data),
        .ddsa_data(ddsa_data),
        .ddsb_data(ddsb_data),
        .aud_in(aud_in[15:8]),
                        
        .usb_rd_data(usb_rd_data),
        .usb_rd_data_valid(usb_rd_valid),
        .usb_rd_full(outa_usb_rd_full),
        
                
        .att(outa_att),
        .amp_en(outa_amp_en),
        .led(outa_led) 
        
//        input [31:0] dds_fm,
//        input [31:0] dds_am
                                     
);

     
    
wire [7:0] outb_data_out;
wire outb_usb_rd_full;
    
dac_channel #(.FAST_FIR("false")) outb_dac_channel (

        
        .clk(clk),
        .reset(reset),
            
        .penable(penable),
        .psel(paddr[31:12] == 20'h43C03),
        .paddr(paddr),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .prdata(outb_prdata),
        
        .dac_data_out(outb_data_out),
                
        .ina_data(ina_data),        
        .inb_data(inb_data),
        .ddsa_data(ddsa_data),
        .ddsb_data(ddsb_data),
        .aud_in(aud_in[15:8]),
        
                        
        .usb_rd_data(usb_rd_data),
        .usb_rd_data_valid(usb_rd_valid),
        .usb_rd_full(outb_usb_rd_full),
        
                
        .att(outb_att),
        .amp_en(outb_amp_en),
        .led(outb_led) 

//        input [31:0] dds_fm,
//        input [31:0] dds_am
                                     
);



max5851_if max5851_if_inst (

    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////
    
        
    .max5851_clk_p(DAC_CLKX_P),
    .max5851_clk_n(DAC_CLKX_N),
    .max5851_clkin(DAC_CLK),
    
    .max5851_dia(DAC_DA),
    .max5851_dib(DAC_DB),
    
    .max5851_cw(DAC_CWN), 
    
    
    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////
    
    .clk(clk),
    .reset(reset),
    
    .dclk(dac_dclk),
    
    .dac_a_data(outa_data_out),
    
    .dac_b_data(outb_data_out),
    
    .cfg(dac_cfg),
    .cfg_wr_en(dac_cfg_wr_en)
);
    
    
      
    
/////////////////////////////////////////////////////////////
//
// FT601 USB3 
// 100MHz 32bit 3.2Gb/s
//
/////////////////////////////////////////////////////////////
    
    

wire [15:0] usb_io = GPIO_0_0_tri_o[47:32];
/*
{
    // Port 1 [7:0]
    1'b0, // SN2
    1'b0, // SN1
    1'b0, // SN0
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    // Port 0 [7:0]
    USB_LED_COM,
    USB_LED_R,
    POWER_LED_R,
    POWER_LED_COM,
    POWER_LED_G,
    POWER_LED_B,
    USB_LED_G,
    USB_LED_B
};
*/

i2c_ioexp usb_i2c_ioexp (

    .clk(clk),
    .reset(reset),
    
    .in(usb_io),
    
    .sclk(USB_IO_CLK),
    .sdata(USB_IO_DATA),
    .sdata_oe_n()
   
);



    
assign usb_wr_data =(usb_wr_mux == 0) ? usb_wr_data_raw :
                    (usb_wr_mux == 1) ? 0 : 
                    (usb_wr_mux == 2) ? ina_data :
                    (usb_wr_mux == 3) ? usb_rd_data : 
                    0; 
                    
assign usb_wr_be   =(usb_wr_mux == 0) ? usb_wr_be_raw :
                    (usb_wr_mux == 1) ? 4'hF : 
                    (usb_wr_mux == 2) ? 4'hF :
                    (usb_wr_mux == 3) ? usb_rd_be : 
                    0; 
  
assign usb_wr_en =  (usb_wr_mux == 0) ? usb_wr_en_raw :
                    (usb_wr_mux == 1) ? 0 : 
                    (usb_wr_mux == 2) ? 1 :
                    (usb_wr_mux == 3) ? usb_rd_valid : 
                    0; 
                      
  
assign usb_rd_en = 1; 


ft601_if ft601_if_inst (

    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////
    
    .ft601_clkin(USB_CLK),
    .ft601_data(USB_D),
    .ft601_be(USB_BE),
    .ft601_txe_n(USB_TXE_N),
    .ft601_rxf_n(USB_RXF_N),
    .ft601_oe_n(USB_OE_N),
    .ft601_wr_n(USB_WR_N),
    .ft601_rd_n(USB_RD_N),
    .ft601_siwu_n(USB_SIWU_N),
    
    
    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////
    
    .clk(clk),
    .reset(reset),

    .wr_data(usb_wr_data),
    .wr_be(usb_wr_be),
    .wr_valid(usb_wr_en),
    .wr_fifo_full(usb_wr_fifo_full),
    
    .rd_data(usb_rd_data),
    .rd_be(usb_rd_be),
    .rd_en(usb_rd_en),
    .rd_valid(usb_rd_valid),
    .rd_fifo_empty(usb_rd_fifo_empty)
    
);
    
    
       
    
/////////////////////////////////////////////////////////////
//
// AIC3204 CODEC
// 192kHz 4x32bit 24.6Mb/s
//
/////////////////////////////////////////////////////////////
    
/*
wire [31:0] nw_fifo_rd_data;
wire nw_fifo_rd_en;
wire nw_fifo_empty;

wire [31:0] pw_fifo_rd_data;
wire pw_fifo_rd_en;
wire pw_fifo_empty;

wire [31:0] nw_fifo_wr_data;
wire nw_fifo_wr_en;
wire nw_fifo_full;

wire [31:0] pw_fifo_wr_data;
wire pw_fifo_wr_en;
wire pw_fifo_full;
    */
    
wire [15:0] codec_io = GPIO_0_0_tri_o[63:48];
/*
{
    // Port 1 [7:0]
    1'b0, // LINE_IN_DET,
    1'b0,
    1'b0,
    1'b0,
    CODEC_RESET_N,
    1'b0, // LINE_IN_DET,
    1'b0, // LINE_IN_DET,
    1'b0,
    // Port 0 [7:0]
    LINE_IN_LED_R,
    LINE_IN_LED_COM,
    LINE_OUT_LED_R,
    LINE_OUT_LED_COM,
    LINE_OUT_LED_G,
    LINE_OUT_LED_B,
    LINE_IN_LED_B,
    LINE_IN_LED_G    
};
*/


i2c_ioexp codec_i2c_ioexp (

    .clk(clk),
    .reset(reset),
    
    .in(codec_io),
    
    .sclk(CODEC_IO_CLK),
    .sdata(CODEC_IO_DATA),
    .sdata_oe_n()
   
);



wire mreset;


xpm_cdc_sync_rst #(
    .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
    .INIT(1),           // DECIMAL; 0=initialize synchronization registers to 0, 1=initialize synchronization
                      // registers to 1
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
)
xpm_cdc_sync_rst_inst (
  .dest_rst(mreset), // 1-bit output: src_rst synchronized to the destination clock domain. This output
                       // is registered.

  .dest_clk(mclk), // 1-bit input: Destination clock.
  .src_rst(reset)    // 1-bit input: Source reset signal.
);





wire [1:0] aud_rate;
wire mpx_sel;

i2s_ctrl ctrl (

    .clk(mclk),
    .reset(mreset),
    .mpx_sel(mpx_sel),
    
    .aud_rate(aud_rate),
    
    .mclk(CODEC_MCLK),
    .bclk(CODEC_BCLK),
    .wclk(CODEC_WCLK)

);



wire [15:0] aud_in_l_m;
wire [15:0] aud_in_r_m;
wire rx_data_valid_m;
wire rx_data_valid_180_m;


i2s_rx
#(
    .SAMPLE_DEPTH(16)
)    
rx
(
    .reset(mreset),
    .mclk(mclk),
    .wclk(CODEC_WCLK),
    .bclk(CODEC_BCLK),
    .din(CODEC_DOUT),
    
    .rx_data_l(aud_in_l_m),
    .rx_data_r(aud_in_r_m),
    .rx_data_valid(rx_data_valid_m),
    .rx_data_valid_180(rx_data_valid_180_m)
    
);



xpm_cdc_handshake #(
  .DEST_EXT_HSK(0),   // DECIMAL; 0=internal handshake, 1=external handshake
  .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
  .SRC_SYNC_FF(3),    // DECIMAL; range: 2-10
  .WIDTH(32)           // DECIMAL; range: 1-1024
)
rx_aud_cdc (
  .dest_out({aud_in_l, aud_in_r}),
  .dest_req(rx_data_valid),
  .src_rcv(/*full*/),
  .dest_clk(clk),
  .src_clk(mclk),
  .src_in({aud_in_l_m, aud_in_r_m}),
  .src_send(rx_data_valid_m)
);

xpm_cdc_handshake #(
  .DEST_EXT_HSK(0),   // DECIMAL; 0=internal handshake, 1=external handshake
  .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
  .SRC_SYNC_FF(3),    // DECIMAL; range: 2-10
  .WIDTH(1)           // DECIMAL; range: 1-1024
)
rx_aud_cdc2 (
  .dest_out(),
  .dest_req(rx_data_valid_180),
  .src_rcv(/*full*/),
  .dest_clk(clk),
  .src_clk(mclk),
  .src_in(0),
  .src_send(rx_data_valid_180_m)
);


wire [15:0] aud_out_l = aud_in_l;
wire [15:0] aud_out_r = aud_in_r;
wire tx_data_valid = rx_data_valid;





wire [15:0] aud_out_l_m;
wire [15:0] aud_out_r_m;
wire tx_data_valid_m;


i2s_tx
#(
    .SAMPLE_DEPTH(16)
)    
tx
(
    .reset(mreset),
    .mclk(mclk),
    .wclk(CODEC_WCLK),
    .bclk(CODEC_BCLK),
    .dout(CODEC_DIN),
    
    .tx_data_l(aud_out_l_m),
    .tx_data_r(aud_out_r_m),
    .tx_data_valid(tx_data_valid_m)
    
    
);



xpm_cdc_handshake #(
  .DEST_EXT_HSK(0),   // DECIMAL; 0=internal handshake, 1=external handshake
  .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
  .SRC_SYNC_FF(3),    // DECIMAL; range: 2-10
  .WIDTH(32)           // DECIMAL; range: 1-1024
)
tx_aud_cdc (
  .dest_out({aud_out_l_m, aud_out_r_m}),
  .dest_req(tx_data_valid_m),
  .src_rcv(/*full*/),
  .dest_clk(mclk),
  .src_clk(clk),
  .src_in({aud_out_l, aud_out_r}),
  .src_send(tx_data_valid)
);

   
   




/*
aic3204_if aic3204_if_inst(
    
    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////

    .aic3204_mclk(CODEC_MCLK),
    .aic3204_wclk(CODEC_WCLK),
    .aic3204_bclk(CODEC_BCLK),
    .aic3204_din(CODEC_DIN),
    .aic3204_dout(CODEC_DOUT),
    

    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////

    .clk(clk),
    .mclk(mclk),
    .reset(reset),
    
    .nw_fifo_rd_data(nw_fifo_rd_data),
    .nw_fifo_rd_en(nw_fifo_rd_en),
    .nw_fifo_empty(nw_fifo_empty),
    
    .pw_fifo_rd_data(pw_fifo_rd_data),
    .pw_fifo_rd_en(pw_fifo_rd_en),
    .pw_fifo_empty(pw_fifo_empty),
    
    .nw_fifo_wr_data(nw_fifo_wr_data),
    .nw_fifo_wr_en(nw_fifo_wr_en),
    .nw_fifo_full(nw_fifo_full),
    
    .pw_fifo_wr_data(pw_fifo_wr_data),
    .pw_fifo_wr_en(pw_fifo_wr_en),
    .pw_fifo_full(pw_fifo_full)


);
*/



    
/////////////////////////////////////////////////////////////
//
// Stereo multiplexer
//
/////////////////////////////////////////////////////////////

wire [15:0] mpx_m;
wire mpx_valid_m;
    
stereo_mpx mpx_inst (
            
    .mclk(mclk),
    .mreset(mreset),
        
    .clk(clk),
    .reset(reset),
    
    .penable(penable),
    .psel(paddr[31:12] == 20'h43C07),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(mpx_prdata),        
    
    .in_l(aud_in_l_m),
    .in_r(aud_in_r_m),
    .in_valid(rx_data_valid_m),    
    .in_valid_180(rx_data_valid_180_m),
    .mpx_sel(mpx_sel),
    
    .mpx_out(mpx_m),
    .mpx_valid(mpx_valid_m)
    
);





wire mpx_sync_valid;
wire signed [15:0] mpx_sync;


xpm_cdc_handshake #(
  .DEST_EXT_HSK(0),   // DECIMAL; 0=internal handshake, 1=external handshake
  .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
  .SRC_SYNC_FF(3),    // DECIMAL; range: 2-10
  .WIDTH(16)           // DECIMAL; range: 1-1024
)
mpx_cdc (
  .dest_out(mpx_sync),
  .dest_req(mpx_sync_valid),
  .dest_clk(clk),
  .src_clk(mclk),
  .src_in(mpx_m),
  .src_send(mpx_valid_m)
);



always @(posedge clk) if (mpx_sync_valid) mpx <= mpx_sync;


    
/////////////////////////////////////////////////////////////
//
// DDS Blocks
//
/////////////////////////////////////////////////////////////

wire [31:0] ddsa_prdata;

dds_block ddsa (
            
    .clk(clk),
    .reset(reset),
        
    .penable(penable),
    .psel(paddr[31:12] == 20'h43C05),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(ddsa_prdata),
            
    .ina_data(ina_data),    
    .inb_data(inb_data),
    .ddsa_data(ddsa_data),
    .ddsb_data(ddsb_data),
    .aud_in(aud_in),
    .mpx_in(mpx),
    
    .dds_data_out(ddsa_data)                                             
);



wire [31:0] ddsb_prdata;

dds_block ddsb (
            
    .clk(clk),
    .reset(reset),
        
    .penable(penable),
    .psel(paddr[31:12] == 20'h43C06),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(ddsb_prdata),
            
    .ina_data(ina_data),    
    .inb_data(inb_data),
    .ddsa_data(ddsa_data),
    .ddsb_data(ddsb_data),
    .aud_in(aud_in),
    .mpx_in(mpx),
    
    .dds_data_out(ddsb_data)                                             
);





assign prdata = 
        ( paddr[15:12] == 4'h0 ) ? ina_prdata :  
        ( paddr[15:12] == 4'h1 ) ? inb_prdata :  
        ( paddr[15:12] == 4'h2 ) ? outa_prdata :  
        ( paddr[15:12] == 4'h3 ) ? outb_prdata :
        ( paddr[15:12] == 4'h4 ) ? regs_prdata :
        ( paddr[15:12] == 4'h5 ) ? ddsa_prdata :
        ( paddr[15:12] == 4'h6 ) ? ddsb_prdata :
        ( paddr[15:12] == 4'h7 ) ? ddsb_prdata :
        'h0;  



r24bb_bd r24bb_bd_inst (

    .pl_clk0(clk),
    .pl_reset_n(pl_reset_n),
    
    .GPIO_0_0_tri_i(GPIO_0_0_tri_i),
    .GPIO_0_0_tri_o(GPIO_0_0_tri_o),
    .GPIO_0_0_tri_t(GPIO_0_0_tri_t),
    
    .apb_paddr(paddr),
    .apb_penable(penable),
    .apb_prdata(prdata),
    .apb_pready(1'b1),
    .apb_psel(psel),
    .apb_pslverr(1'b0),
    .apb_pwdata(pwdata),
    .apb_pwrite(pwrite)   

);


    
   
    
regs regs_inst (

    .clk(pl_clk0),
    .reset(reset), 
        
    .penable(penable),
    .psel(paddr[31:12] == 20'h43C04),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(regs_prdata),

    .leds({LED1, LED0}),
            
    .usb_wr_data(usb_wr_data_raw),
    .usb_wr_be(usb_wr_be_raw),
    .usb_wr_en(usb_wr_en_raw),
    .usb_wr_fifo_full(usb_wr_fifo_full),
    
    .usb_rd_data(),
    .usb_rd_be(),
    .usb_rd_en(),
    .usb_rd_fifo_empty(usb_rd_fifo_empty),
    
    .usb_wr_mux(usb_wr_mux),
        
    .dac_cfg(dac_cfg),
    .dac_cfg_wr_en(dac_cfg_wr_en),
    
    .dac_dce(dac_dce),
    
    .aud_rate(aud_rate)
                
);    
    
    
    
    
endmodule
