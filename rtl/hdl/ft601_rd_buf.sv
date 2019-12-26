
module ft601_rd_buf 
#(
    parameter N
)
(    
    input rd_reset,
    input rd_clk,
    output [35:0] rd_data,
    output rd_valid,
    input rd_en,
    input rd_ce,
    output rd_empty,
    output rd_aempty,
        
    input wr_reset,
    input wr_clk,
    input [35:0] wr_data,
    input ft_rxf_n,
    input ft_rd_n,
    input wr_ce,
    output wr_full,
    output wr_afull,
    output wr_ready
);
    

wire wr_en = !ft_rxf_n && !ft_rd_n && wr_ce;


xpm_fifo_async #(
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(36),      // DECIMAL
    .WRITE_DATA_WIDTH(36),     // DECIMAL
    .USE_ADV_FEATURES("1F0F") // Enable almost_empty, almost_full, and data_valid
)
rd_fifo (

    .rst(wr_reset),   
    
    .wr_clk(!wr_clk),
    .din(wr_data),      
    .wr_en(wr_en),    
    .full(wr_full),
    .almost_full(wr_afull),
    
    .rd_clk(rd_clk), 
    .dout(rd_data),  
    .data_valid(rd_valid),
    .rd_en(rd_en && rd_ce),
    .empty(rd_empty),
    .almost_empty(rd_aempty)
);

    

xpm_cdc_single ready_cdc (
    .src_clk(rd_clk),
    .src_in(rd_empty),
    .dest_clk(!wr_clk),
    .dest_out(wr_ready)
);

    
    
    
endmodule
