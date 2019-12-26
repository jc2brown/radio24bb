
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
    output reg writeable,
    output almost_unwriteable,
    
    input rd_reset,
    input rd_clk,
    output [35:0] rd_data,
    output rd_valid,
    input ft_txe_n,
    input ft_wr_n,
    input rd_ce,    
    output rd_empty,
    output rd_aempty,
    output reg readable
);
    

wire rd_done;

wire rd_en = !ft_txe_n && !ft_wr_n && rd_ce;

reg [12:0] wr_data_count;

wire full = (wr_data_count == 4096);
wire almost_full = (wr_data_count >= 4095);

assign almost_unwriteable = almost_full;

reg rd_done_d1;
always @(posedge wr_clk) rd_done_d1 <= rd_done;


always @(posedge wr_clk) begin
    if (wr_reset) begin
        writeable <= 1;
    end
    else begin
        if (wr_ce && ((almost_full && wr_en) || wr_push)) begin
            writeable <= 0;
        end
        else if (rd_done && !rd_done_d1) begin
            writeable <= 1;
        end 
    end
end


always @(posedge wr_clk) begin
    if (wr_reset) begin
        wr_data_count <= 0;
    end
    else begin
        if (wr_en && wr_ce) begin
            wr_data_count <= wr_data_count + 1;
        end
        else if (rd_done && !rd_done_d1) begin
            wr_data_count <= 0;
        end
    end
end


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
wr_fifo (

    .rst(wr_reset),   
    
    .wr_clk(wr_clk),
    .din(wr_data),      
    .wr_en(wr_en && wr_ce),    
    
    .rd_clk(!rd_clk), 
    .dout(rd_data),  
    .data_valid(rd_valid),
    .rd_en(rd_en),
    .empty(rd_empty),
    .almost_empty(rd_aempty)
);

    
wire rd_pending;

reg rd_pending_d1;
always @(negedge rd_clk) rd_pending_d1 <= rd_pending;
    
    
always @(posedge wr_clk) begin
    if (rd_reset) begin
        readable <= 0;
    end
    else begin
        if (rd_pending && !rd_pending_d1) begin
            readable <= 1;
        end
        else if (rd_empty) begin
            readable <= 0;
        end 
    end
end


xpm_cdc_single rd_done_cdc (
    .src_clk(!rd_clk),
    .src_in(rd_empty),
    .dest_clk(wr_clk),
    .dest_out(rd_done)
);


xpm_cdc_single ready_cdc (
    .src_clk(wr_clk),
    .src_in(!writeable),
    .dest_clk(!rd_clk),
    .dest_out(rd_pending)
);

    
    
    
endmodule
