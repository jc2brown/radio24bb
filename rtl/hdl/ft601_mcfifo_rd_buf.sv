

module ft601_mcfifo_rd_buf 
#(
    parameter CAPACITY = 8192 // bytes 
)
(    
    
    input wr_reset,
    input wr_clk,
    input [31:0] wr_data,
    input [3:0] wr_be,
    input wr_en,
        
    output wr_full,
    output wr_almost_full,
    output wr_has_packet_space, // Asserted when a device can write at least an entire packet's worth of data without the buffer becoming full
    
    
    input rd_reset,
    input rd_clk,
    output [31:0] rd_data,
    output [3:0] rd_be,
    output rd_valid,
    input rd_en,
    output rd_empty,
    output rd_almost_empty
);
   
   
   
localparam BYTES_PER_WORD = 4;

localparam LARGEST_PAPCKET_SIZE = 4096; //bytes



wire prog_full; // Asserted when there is less than one full packet of space available for writing

assign wr_has_packet_space = !prog_full;



xpm_fifo_async #(
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(1),     // DECIMAL
    
    .FIFO_WRITE_DEPTH(CAPACITY/BYTES_PER_WORD),   
    
    .READ_DATA_WIDTH(9*BYTES_PER_WORD),      // DECIMAL
    .WRITE_DATA_WIDTH(9*BYTES_PER_WORD),     // DECIMAL
    .USE_ADV_FEATURES("1F0F"), // Enable almost_empty, almost_full, and data_valid
    .PROG_FULL_THRESHOLD((CAPACITY-LARGEST_PAPCKET_SIZE)/BYTES_PER_WORD)
)
rd_fifo (

    .rst(wr_reset),   
    
    .wr_clk(!wr_clk),
    .din({wr_be, wr_data}),      
    .wr_en(wr_en),  
    .full(wr_full),
    .almost_full(wr_almost_full),
    .prog_full(prog_full),
    
    .rd_clk(rd_clk), 
    .dout({rd_be, rd_data}),  
    .data_valid(rd_valid),
    .rd_en(rd_en),
    .empty(rd_empty),
    .almost_empty(rd_almost_empty)
    
);

 
   
   
   
   
   
   
   
endmodule
