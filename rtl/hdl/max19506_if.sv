`timescale 1ps / 1ps


module max19506_if (
    
    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////
    
    output wire max19506_clkout_n,
    output wire max19506_clkout_p,

    input wire max19506_dclka,
    input wire [7:0] max19506_doa,
    input wire max19506_dora,
    
    input wire max19506_dclkb,
    input wire [7:0] max19506_dob,
    input wire max19506_dorb,
    
    
    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////

    input wire clk,
    input wire reset,
    
    input wire adc_dclk,
            
    output wire [7:0] adc_a_data,
    output wire adc_a_dor,
    input wire adc_a_rden,
    output wire adc_a_empty,
        
    output wire [7:0] adc_b_data,
    output wire adc_b_dor,
    input wire adc_b_rden,
    output wire adc_b_empty
      
    
);




/////////////////////////////////////////////////////////////
//
// Output Registers
//
/////////////////////////////////////////////////////////////


ODDR clkout_p_oddr_inst (
    .Q(max19506_clkout_p),
    .D1(1'b1),
    .D2(1'b0),
    .C(adc_dclk),
    .S(),
    .R(reset)
);

ODDR clkout_n_oddr_inst (
    .Q(max19506_clkout_n),
    .D1(1'b0),
    .D2(1'b1),
    .C(adc_dclk),
    .S(),
    .R(reset)
);





    


/////////////////////////////////////////////////////////////
//
// Input CDC FIFO
//
/////////////////////////////////////////////////////////////

wire [7:0] doa_infifo;
wire dora_infifo;

wire [7:0] dob_infifo;
wire dorb_infifo;


IN_FIFO
#(
    .ARRAY_MODE("ARRAY_MODE_4_X_4")
)
doa_infifo_inst (
    .RESET(1'b0),
    
    .WRCLK(max19506_dclka),
    .WREN(1'b1),
    .D0(max19506_doa[3:0]),
    .D1(max19506_doa[7:4]),
    .D2({3'b000, max19506_dora}),
    
    .RDCLK(clk),
    .RDEN(1'b1),
    .Q0(doa_infifo[3:0]),
    .Q1(doa_infifo[7:4]),
    .Q2(dora_infifo)

);


IN_FIFO
#(
    .ARRAY_MODE("ARRAY_MODE_4_X_4")
)
dob_infifo_inst (
    .RESET(1'b0),
    
    .WRCLK(max19506_dclkb),
    .WREN(1'b1),
    .D0(max19506_dob[3:0]),
    .D1(max19506_dob[7:4]),
    .D2({3'b000, max19506_dorb}),
    
    .RDCLK(clk),
    .RDEN(1'b1),
    .Q0(dob_infifo[3:0]),
    .Q1(dob_infifo[7:4]),
    .Q2(dorb_infifo)

);


/////////////////////////////////////////////////////////////
//
// Bulk FIFO
//
/////////////////////////////////////////////////////////////



xpm_fifo_async #(
    .CDC_SYNC_STAGES(2),       // DECIMAL
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(9),      // DECIMAL
    .WRITE_DATA_WIDTH(9)     // DECIMAL
)
adc_a_fifo_inst (

    .rst(reset),   
    
    .wr_clk(max19506_dclka),
    .din({dora_infifo, doa_infifo}),      
    .wr_en(1'b1),    
    
    .rd_clk(clk),
    .dout({adc_a_dor, adc_a_data}),  
    .rd_en(adc_a_rden),    
    .empty(adc_a_empty)
);



xpm_fifo_async #(
    .CDC_SYNC_STAGES(2),       // DECIMAL
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(9),      // DECIMAL
    .WRITE_DATA_WIDTH(9)     // DECIMAL
)
adc_b_fifo_inst (

    .rst(reset),   
    
    .wr_clk(max19506_dclkb),
    .din({dorb_infifo, dob_infifo}),      
    .wr_en(1'b1),    
    
    .rd_clk(clk),
    .dout({adc_b_dor, adc_b_data}),  
    .rd_en(adc_b_rden),    
    .empty(adc_b_empty)  
);








endmodule
