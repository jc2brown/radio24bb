`timescale 1ps / 1ps


module ft601_mcfifo 
#(
    parameter NUM_CHANNELS = 4,
    parameter MAX_PACKET_SIZE = 1024
)
(
    input wire reset_n,

    output clk_out,
    inout wire [31:0] data,    // [7:0] channel address
    inout wire [3:0] be,       // [3:0] command (0=read, 1=write)
    input wire oe_n,    // Not used
    input wire wr_n,    // Transaction request input
    input wire rd_n,    // Not used
    output reg txe_n,   // Optional: status valid output
    output reg rxf_n,   // Data receive acknowledge output
    input wire siwu_n   // Reserved, tie high
    
        
    
);





wire [31:0]   wr_ch_wr_data             [NUM_CHANNELS:1];
wire [3:0]    wr_ch_wr_be               [NUM_CHANNELS:1];
wire          wr_ch_wr_en               [NUM_CHANNELS:1];
wire          wr_ch_wr_push             [NUM_CHANNELS:1];

wire         wr_ch_wr_full             [NUM_CHANNELS:1];
wire         wr_ch_wr_almost_full      [NUM_CHANNELS:1];
wire         wr_ch_has_wr_packet_space [NUM_CHANNELS:1];


reg [31:0]   rd_ch_rd_data             [NUM_CHANNELS:1];
reg [3:0]    rd_ch_rd_be               [NUM_CHANNELS:1];
wire       [NUM_CHANNELS:1]    rd_ch_rd_en;//               = {NUM_CHANNELS{1'b1}};
reg          rd_ch_rd_valid            [NUM_CHANNELS:1];

wire         rd_ch_rd_empty            [NUM_CHANNELS:1];
wire         rd_ch_rd_almost_empty     [NUM_CHANNELS:1];
    
    
    
        
localparam BYTES_PER_WORD = 4;
        

reg clk = 1;
always #4995 clk <= !clk; // Slightly faster than 100MHz

assign clk_out = clk;

//reg reset = 1; 
//initial #50000 reset <= 0;

wire reset = !reset_n;


wire [31:0] data_in;
wire [31:0] data_out;
reg [31:0] data_oe_n;

IOBUF data_iobuf [31:0] (
    .IO(data),
    .I(data_out),
    .O(data_in),
    .T(data_oe_n)
);



wire [3:0] be_in;
reg [3:0] be_out;
reg [3:0] be_oe_n;


IOBUF be_iobuf [3:0] (
    .IO(be),
    .I(be_out),
    .O(be_in),
    .T(be_oe_n)
);




reg [3:0] state;

localparam STATE_RESET = 0;
localparam STATE_IDLE = 1;

localparam STATE_READ_BTA1 = 2;
localparam STATE_READ_BTA2 = 3;
localparam STATE_READ_DATA = 4;
localparam STATE_READ_BTA3 = 5;

localparam STATE_WRITE_BTA1 = 6;
localparam STATE_WRITE_DATA = 7;
localparam STATE_WRITE_BTA2 = 8;


reg [31:0] reset_count;


reg [31:0] rd_count;

always @(negedge clk) begin
    if (state == STATE_READ_BTA2) begin
        rd_count <= MAX_PACKET_SIZE/BYTES_PER_WORD;
    end 
    else if (state == STATE_READ_DATA) begin
        rd_count <= rd_count - 1; // Should never become negative if we handle rd_almost_empty properly
    end
end

wire rd_almost_empty = (rd_count == 0);



reg [31:0] wr_count;

always @(negedge clk) begin
    if (state == STATE_WRITE_BTA1) begin
        wr_count <= MAX_PACKET_SIZE/BYTES_PER_WORD;
    end 
    else if (state == STATE_WRITE_DATA) begin
        wr_count <= wr_count - 1; // Should never become negative if we handle wr_almost_full properly
    end
end

wire wr_almost_full = (wr_count == 1);



reg [7:0] channel;









wire [31:0] wr_ch_rd_data [NUM_CHANNELS:1];
wire [3:0] wr_ch_rd_be [NUM_CHANNELS:1];
wire wr_ch_rd_en [NUM_CHANNELS:1];

genvar ch;
for (ch=1; ch<=NUM_CHANNELS; ch=ch+1) begin
    assign wr_ch_rd_en[ch] = (state == STATE_READ_DATA) && !wr_n && !rxf_n && (channel == ch);
end


wire wr_ch_rd_valid [NUM_CHANNELS:1];

wire [NUM_CHANNELS:1] wr_ch_rd_xfer_req;
wire [NUM_CHANNELS:1] wr_ch_rd_xfer_done;// [NUM_CHANNELS:1];
wire wr_ch_rd_xfer_almost_done [NUM_CHANNELS:1];



wire rd_ch_wr_en [NUM_CHANNELS:1];
for (ch=1; ch<=NUM_CHANNELS; ch=ch+1) begin
    assign rd_ch_wr_en[ch] = (state == STATE_WRITE_DATA) && !wr_n && !rxf_n && (channel == ch);
end


wire [NUM_CHANNELS:1] rd_ch_wr_full;// [NUM_CHANNELS:1];
wire rd_ch_wr_almost_full [NUM_CHANNELS:1];
wire [NUM_CHANNELS:1] rd_ch_has_wr_packet_space ;



assign data_out = 
    (state == STATE_READ_DATA) ? wr_ch_rd_data[channel] : 
    {16'h0, {{(4-NUM_CHANNELS){1'b1}}, ~wr_ch_rd_xfer_req}, {{(4-NUM_CHANNELS){1'b1}}, ~rd_ch_has_wr_packet_space}, 8'h0};


assign be_out = (state == STATE_READ_DATA) ? wr_ch_rd_be[channel] : 4'h0;




// From PC to FPGA
// Transfer up to MAX_PACKET_SIZE bytes per xfer
ft601_mcfifo_wr_buf 
#(
    .CAPACITY(2*MAX_PACKET_SIZE), // bytes 
    .MAX_PACKET_SIZE(MAX_PACKET_SIZE)
)
wr_buf [NUM_CHANNELS:1]
(
    
    .wr_reset(reset),
    .wr_clk(!clk), // negedge within FT601 domain
    
    .wr_data(wr_ch_wr_data),
    .wr_be(wr_ch_wr_be),
    .wr_en(wr_ch_wr_en),
//    .wr_en(1'b0),
    .wr_push(wr_ch_wr_push),
    
    .wr_full(wr_ch_wr_full),
    .wr_almost_full(wr_ch_wr_almost_full),
    .wr_has_packet_space(wr_ch_has_wr_packet_space), // Asserted when a device can write at least an entire packet's worth of data without the buffer becoming full
            
    .rd_reset(reset),
    .rd_clk(!clk), // negedge per IF spec
    
    .rd_data(wr_ch_rd_data),
    .rd_be(wr_ch_rd_be),
    .rd_valid(wr_ch_rd_valid),
    .rd_en(wr_ch_rd_en),    
    
    .rd_xfer_done(wr_ch_rd_xfer_done),
    .rd_xfer_almost_done(wr_ch_rd_xfer_almost_done),
    .rd_xfer_req(wr_ch_rd_xfer_req)

);


genvar i;
generate
for (i=1; i<=NUM_CHANNELS; i=i+1) begin


    ft601_data_source 
    #(
        .MAX_PACKET_SIZE(MAX_PACKET_SIZE),
        .CHANNEL_NUM(i)
    )
    src
    (
    
        .reset(reset),
        .clk(!clk), // negedge within FT601 domain
        
        .pc_tx_data(wr_ch_wr_data[i]),
        .pc_tx_be(wr_ch_wr_be[i]),
        .pc_tx_en(wr_ch_wr_en[i]),
        .pc_tx_push(wr_ch_wr_push[i]),
        
        .pc_tx_full(wr_ch_wr_full[i])
                  
    );
    
    
    
    ft601_data_sink
        #(
            .MAX_PACKET_SIZE(MAX_PACKET_SIZE),
            .CHANNEL_NUM(i)
        )
        sink
        (
        
            .reset(reset),
            .clk(!clk), // negedge within FT601 domain
            
            .pc_rx_data(rd_ch_rd_data[i]),
            .pc_rx_be(rd_ch_rd_be[i]),
            .pc_rx_rd_en(rd_ch_rd_en[i]),
            .pc_rx_valid(rd_ch_rd_valid[i]),
            
            .pc_rx_empty(rd_ch_rd_empty[i])
                      
        );
    
    
end
endgenerate








// From FPGA to PC
ft601_mcfifo_rd_buf 
#(
    .CAPACITY(2*MAX_PACKET_SIZE), // bytes 
    .MAX_PACKET_SIZE(MAX_PACKET_SIZE)
)
rd_buf [NUM_CHANNELS:1]
(
           
    .wr_reset(reset),
    .wr_clk(clk), // posedge to sample data in middle of stable region
    .wr_data(data_in),
    .wr_be(be_in),
    .wr_en(rd_ch_wr_en),
    
    .wr_full(rd_ch_wr_full),
    .wr_almost_full(rd_ch_wr_almost_full),
    .wr_has_packet_space(rd_ch_has_wr_packet_space),
    
    .rd_reset(reset),
    .rd_clk(!clk), // negedge within FT601 domain
    .rd_data(rd_ch_rd_data),
    .rd_be(rd_ch_rd_be),
    .rd_valid(rd_ch_rd_valid),
    .rd_en(rd_ch_rd_en),
    .rd_empty(rd_ch_rd_empty),
    .rd_almost_empty(rd_ch_rd_almost_empty)
    
);









always @(negedge clk) begin
    if (reset) begin
    
        txe_n <= 1'b0;
        rxf_n <= 1'b1;
    
        data_oe_n <= 32'hFFFFFFFF;
        be_oe_n <= 4'hF;
        channel <= 0;
        reset_count <= 0;
        state <= STATE_RESET;
    end
    else begin
        if (state == STATE_RESET) begin
            data_oe_n <= 32'hFFFF00FF;
            be_oe_n <= 4'hF;
            if (reset_count == 100) begin
                state <= STATE_IDLE;
            end
            else begin
                reset_count <= reset_count + 1;
            end
        end
        else if (state == STATE_IDLE) begin
            txe_n <= 1'b0;
            if (!wr_n) begin
                channel <= data_in[7:0];
                txe_n <= 1'b1;
                if (be_in == 4'h0) begin  // Master read
                    state <= STATE_READ_BTA1;
                end
                else if (be_in == 4'h1) begin  // Master write
                    state <= STATE_WRITE_BTA1;
                end
            end
        end
    
        else if (state == STATE_READ_BTA1) begin
            data_oe_n <= 32'h00000000;
            be_oe_n <= 4'h0;
            state <= STATE_READ_BTA2;
        end 
        else if (state == STATE_READ_BTA2) begin
            rxf_n <= 1'b0;
            state <= STATE_READ_DATA;
        end 
        else if (state == STATE_READ_DATA) begin
//            if (rd_almost_empty || wr_n) begin
            if (wr_ch_rd_xfer_almost_done[channel] || wr_n) begin
                rxf_n <= 1'b1;
                state <= STATE_READ_BTA3;
            end
        end 
        else if (state == STATE_READ_BTA3) begin
            data_oe_n <= 32'hFFFF00FF;
            be_oe_n <= 4'hF;
            channel <= 8'h00;
            txe_n <= 1'b0;
            state <= STATE_IDLE;
        end 
        
        
        
        else if (state == STATE_WRITE_BTA1) begin
            data_oe_n <= 32'hFFFFFFFF;
            rxf_n <= 1'b0;
            state <= STATE_WRITE_DATA;    
        end
                        
        else if (state == STATE_WRITE_DATA) begin
            if (wr_almost_full) begin
                rxf_n <= 1'b1;
            end
            if (wr_almost_full || wr_n) begin
                state <= STATE_WRITE_BTA2;    
            end
        end
        
        else if (state == STATE_WRITE_BTA2) begin
            channel <= 8'h00;
            txe_n <= 1'b0;
            rxf_n <= 1'b1;
            data_oe_n <= 32'hFFFF00FF;
            state <= STATE_IDLE;    
        end
        
    end
end






endmodule
