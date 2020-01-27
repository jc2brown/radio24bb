

// This module implements an asynchronous FIFO which packetizes data flowing from FPGA logic to the FT601.
//
// The buffer is sized to contain at least 2 full data packets. The allowable packet size depends on the number of channels
// in use, but the maximum is 4096 bytes. 
//
// The main requirement of the buffer is to ensure that a complete packet can be written to or read from the FT601 in a contiguous burst.
// To support the clock domain crossing, this module also includes asynchronous transfer request handshaking logic
//
// Packets may be any size up to the maximum, which is determined by the number of channels in use.
// If the buffer is filled with enough data to fill a maximum-sized packet, it will automatically initiate a transfer request.
// For packets smaller than the maximum size, the wr_push signal can be asserted to instruct the buffer to send its contents immediately 
//
// Only one transfer request may be active at a time. 
//

 
    
    
    
    

module ft601_mcfifo_wr_buf 
#(
    parameter CAPACITY = 8192 // bytes 
)
(    

    // Depends on number of channels in use: 1:4096, 2:2048, 4:1024
    // Must not be changed while USB tranfers are active
    // Determines behaviour of control signals (readable/writeable) 
    input [31:0] max_packet_size, 
    
    input wr_reset,
    input wr_clk,
    
    input [31:0] wr_data,
    input [3:0] wr_be,
    input wr_en,
    input wr_push,
        
    output wr_full,
    output wr_almost_full,
    output wr_has_packet_space, // Asserted when a device can write at least an entire packet's worth of data without the buffer becoming full
    
    
    input rd_reset,
    input rd_clk,
    output [31:0] rd_data,
    output [3:0] rd_be,
    output rd_valid,
    input rd_en,    
    
    output rd_xfer_req,
    output rd_xfer_done,
    output rd_xfer_almost_done
    
);
    
    
localparam BYTES_PER_WORD = 4;


localparam STATE_IDLE = 1;
localparam STATE_REQ = 2;
localparam STATE_REQ_ACK = 3;
localparam STATE_WAIT_UNTIL_DONE = 4;
localparam STATE_ACK_DONE = 5;

reg [2:0] state;
    
reg [15:0] wr_data_count; //bytes

wire has_full_packet;

reg wr_xfer_active; // Assert to send, and must stay high until ack
wire wr_xfer_done;
reg [15:0] wr_xfer_size; // bytes

wire [15:0] rd_xfer_size;
reg [15:0] rd_xfer_count;

// This signal stays high for some cycles after finishing the tracnfer
// The external version is driven low immediately to avoid re-triggering the arbiter
wire rd_xfer_req_int; 



assign wr_has_packet_space = (wr_data_count <= CAPACITY - max_packet_size);
assign has_full_packet = (wr_data_count >= max_packet_size);
assign wr_full = (wr_data_count == CAPACITY);
assign wr_almost_full = (wr_data_count >= CAPACITY-BYTES_PER_WORD);




always @(posedge wr_clk) begin
    if (wr_reset) begin
        state <= STATE_IDLE;
        wr_xfer_active <= 0;
        wr_xfer_size <= 0;
    end
    else begin
        if (state == STATE_IDLE) begin
            wr_xfer_active <= 0;
            wr_xfer_size <= 0;
            if (has_full_packet || wr_push) begin
                state <= STATE_REQ;
            end
        end
        else if (state == STATE_REQ) begin
            wr_xfer_active <= 1;
            wr_xfer_size <= has_full_packet ? max_packet_size : wr_data_count;
            state <= STATE_REQ_ACK;
        end
        else if (state == STATE_REQ_ACK) begin
            if (!wr_xfer_done) begin
                state <= STATE_WAIT_UNTIL_DONE;
            end    
        end
        else if (state == STATE_WAIT_UNTIL_DONE) begin
            if (wr_xfer_done) begin
                state <= STATE_ACK_DONE;
            end      
        end   
        else if (state == STATE_ACK_DONE) begin
            state <= STATE_IDLE;                
        end   
    end
end 

    

always @(posedge wr_clk) begin
    if (wr_reset) begin
        wr_data_count <= 0;
    end
    else begin    
        wr_data_count <= wr_data_count 
                        + (wr_en ? BYTES_PER_WORD : 0)
                        - ((state == STATE_ACK_DONE) ? wr_xfer_size : 0);
    end
end




xpm_fifo_async #(
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(1),     // DECIMAL
    
    .FIFO_WRITE_DEPTH(CAPACITY/BYTES_PER_WORD),   
    
    .READ_DATA_WIDTH(9*BYTES_PER_WORD),      // DECIMAL
    .WRITE_DATA_WIDTH(9*BYTES_PER_WORD),     // DECIMAL
    .USE_ADV_FEATURES("1F0F") // Enable almost_empty, almost_full, and data_valid
)
wr_fifo (

    .rst(wr_reset),   
    
    .wr_clk(wr_clk),
    .din({wr_be, wr_data}),      
    .wr_en(wr_en),    
    
    .rd_clk(!rd_clk), 
    .dout({rd_be, rd_data}),  
    .data_valid(rd_valid),
    .rd_en(rd_en)
);

 

    
xpm_cdc_handshake #(
    .DEST_EXT_HSK(1),   // DECIMAL; 0=internal handshake, 1=external handshake
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_SYNC_FF(2),    // DECIMAL; range: 2-10
    .WIDTH(16)           // DECIMAL; range: 1-1024
)
xpm_cdc_handshake_inst (

    .src_clk(wr_clk),
    .src_in(wr_xfer_size),  
    .src_send(wr_xfer_active),
    .src_rcv(wr_xfer_done), 
    
    .dest_clk(!rd_clk),
    .dest_out(rd_xfer_size), 
    .dest_req(rd_xfer_req_int),
    .dest_ack(rd_xfer_done)    
);



assign rd_xfer_done = (rd_xfer_count == rd_xfer_size);
assign rd_xfer_almost_done = (rd_xfer_count == (rd_xfer_size - BYTES_PER_WORD));
 


assign rd_xfer_req = (rd_xfer_done ? 0 : rd_xfer_req_int);


always @(negedge rd_clk) begin
    if (rd_reset || !rd_xfer_req_int) begin
        rd_xfer_count <= 0;
    end
    else if (rd_en) begin
        rd_xfer_count <= rd_xfer_count + BYTES_PER_WORD;
    end
end
    
       
    
endmodule
