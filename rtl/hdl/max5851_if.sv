`timescale 1ps / 1ps


// When SOURCE_SYNCHRONOUS is `defined, the data is clocked out on the falling edge of the locally-generated sample clock `dclk`
// When not defined, data is clocked out on the falling edge of the return clock `max19506_clkin` 
//
`define SOURCE_SYNCHRONOUS

module max5851_if(

    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////
    
    output wire max5851_clk_p,
    output wire max5851_clk_n,
    output wire max5851_clkin,
        
    output wire [7:0] max5851_dia,
    output wire [7:0] max5851_dib,
    
    output wire max5851_cw, 
    
    
    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////
    
    input wire reset,
    input wire clk,
    
    input wire dclk,
    
    input wire [7:0] dac_a_data,
    
    input wire [7:0] dac_b_data,
    
    input wire [7:0] cfg,
    input wire cfg_wr_en
    
);


/////////////////////////////////////////////////////////////
//
// Bulk FIFO
//
/////////////////////////////////////////////////////////////

wire [7:0] dia_fifo_o;
wire [7:0] dib_fifo_o;

//wire [7:0] dia_fifo = dia_fifo_o + 128;
wire [7:0] dib_fifo = dib_fifo_o + 128;


reg [2:0] bytes_avail = 0;
reg [31:0] dia_fifo_buffer;
reg [7:0] dia;


assign dia_fifo_o = dac_a_data;

assign dib_fifo_o = dac_b_data;


/////////////////////////////////////////////////////////////
//
// Output CDC FIFO
//
/////////////////////////////////////////////////////////////


wire [7:0] dia_cw = cfg_wr_en ? cfg : dia_fifo_o[7:0] + 128;

OUT_FIFO 
#(
    .ARRAY_MODE("ARRAY_MODE_4_X_4")
)
max5851_dia_inst (
    .RESET(1'b0),
    
    .WRCLK(clk),
    .WREN(1'b1),
    .D0(dia_cw[3:0]),
    .D1(dia_cw[7:4]),
    .D2({3'b000, !cfg_wr_en}),
    
`ifdef SOURCE_SYNCHRONOUS
    .RDCLK(!dclk),
`else
    .RDCLK(!max5851_clkin),
`endif
    .RDEN(1'b1),
    .Q0(max5851_dia[3:0]),
    .Q1(max5851_dia[7:4]),
    .Q2(max5851_cw)

);


OUT_FIFO 
#(
    .ARRAY_MODE("ARRAY_MODE_4_X_4")
)
max5851_dib_inst (
    .RESET(1'b0),
    
    .WRCLK(clk),
    .WREN(1'b1),
    .D0(dib_fifo[3:0]),
    .D1(dib_fifo[7:4]),
        
`ifdef SOURCE_SYNCHRONOUS
    .RDCLK(!dclk),
`else
    .RDCLK(!max5851_clkin),
`endif
    .RDEN(1'b1),
    .Q0(max5851_dib[3:0]),
    .Q1(max5851_dib[7:4])

);



/////////////////////////////////////////////////////////////
//
// Output Registers
//
/////////////////////////////////////////////////////////////


ODDR clk_p_oddr_inst (
    .Q(max5851_clk_p),
    .D1(1'b1),
    .D2(1'b0),
    .C(dclk),
    .S(),
    .R(reset)
);

ODDR clk_n_oddr_inst (
    .Q(max5851_clk_n),
    .D1(1'b0),
    .D2(1'b1),
    .C(dclk),
    .S(),
    .R(reset)
);



ODDR clkin_oddr_inst (
    .Q(max5851_clkin),
    .D1(1'b1),
    .D2(1'b0),
    .C(dclk),
    .S(),
    .R(reset)
);


    
endmodule
