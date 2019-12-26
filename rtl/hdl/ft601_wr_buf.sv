
module ft601_wr_buf 
#(
    parameter N
)
(    
    input wr_reset,
    input wr_clk,
    input [35:0] wr_data,
    input wr_ce,
    input wr_en,
    input wr_push,
    output wr_afull, 
    output writeable,
    
    input rd_reset,
    input rd_clk,
    output [35:0] rd_data,
    output rd_valid,
    input ft_txe_n,
    input ft_wr_n,
    input rd_ce,    
    output rd_empty,
    output rd_aempty,
    output readable
);
    

wire wr_full;
reg push_req;
wire push_ack;


wire rd_en = !ft_txe_n && !ft_wr_n && rd_ce;

assign writeable = !(wr_afull || push_req);


always @(posedge wr_clk) begin
    if (wr_reset) begin
        push_req <= 0;
    end
    else begin
        if (wr_afull || (wr_push && wr_ce)) begin
            push_req <= 1;
        end
        else if (push_ack) begin
            push_req <= 0;
        end 
    end
end


xpm_fifo_async #(
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(1),     // DECIMA
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(36),      // DECIMAL
    .WRITE_DATA_WIDTH(36),     // DECIMAL
    .USE_ADV_FEATURES("1F0F") // Enable almost_empty, almost_full, and data_valid
)
wr_fifo (

    .rst(wr_reset),   
    
    .wr_clk(wr_clk),
    .din(wr_data),      
    .wr_en(wr_en && wr_ce),    
    .full(wr_full),
    .almost_full(wr_afull),
    
    .rd_clk(!rd_clk), 
    .dout(rd_data),  
    .data_valid(rd_valid),
    .rd_en(rd_en),
    .empty(rd_empty),
    .almost_empty(rd_aempty)
);

    

xpm_cdc_single push_ack_cdc (
    .src_clk(!rd_clk),
    .src_in(rd_empty),
    .dest_clk(wr_clk),
    .dest_out(push_ack)
);


xpm_cdc_single ready_cdc (
    .src_clk(wr_clk),
    .src_in(!writeable),
    .dest_clk(!rd_clk),
    .dest_out(readable)
);

    
    
    
endmodule
