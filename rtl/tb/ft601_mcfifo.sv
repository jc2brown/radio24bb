`timescale 1ps / 1ps


module ft601_mcfifo (
    input wire reset_n,

    output reg clk_out,
    inout wire [31:0] data,    // [7:0] channel address
    inout wire [3:0] be,       // [3:0] command (0=read, 1=write)
    input wire oe_n,    // Not used
    input wire wr_n,    // Transaction request input
    input wire rd_n,    // Not used
    output reg txe_n,   // Optional: status valid output
    output reg rxf_n,   // Data receive acknowledge output
    input wire siwu_n   // Reserved, tie high
    
);


initial clk_out = 1;

always #5000 begin
    clk_out <= !clk_out;
end


wire [31:0] data_in;
reg [31:0] data_out;
reg [31:0] data_oe;

IOBUF data_iobuf [31:0] (
    .IO(data),
    .I(data_out),
    .O(data_in),
    .T(!data_oe)
);



wire [3:0] be_in;
reg [3:0] be_out;
reg [3:0] be_oe;


IOBUF be_iobuf [3:0] (
    .IO(be),
    .I(be_out),
    .O(be_in),
    .T(!be_oe)
);


// FPGA may read when not empty
wire ch1_empty = 1;
wire ch2_empty = 1;
wire ch3_empty = 1;
wire ch4_empty = 1;


// FPGA may write when not full
wire ch1_full = 1;
wire ch2_full = 1;
wire ch3_full = 1;
wire ch4_full = 1;



initial begin

    txe_n <= 1'b0;
    rxf_n <= 1'b1;

    data_out[15:8] <= 8'hFF;
    data_oe[15:8] <= 8'hFF;
/*
    data_out[7:0] <= 8'hFF;
    data_oe[7:0] <= 8'h00;

    data_out[31:16] <= 16'hFFFF;
    data_oe[31:16] <= 16'h0000;
   
    be_out[3:0] <= 4'hF;
    be_out[3:0] <= 4'h0;


    // Read 

    // Idle
    repeat (10) @(negedge clk_out);

    // Read.Command
    @(negedge clk_out) begin
        data_out[7:0] <= 8'h01;
        be_out[3:0] <= 4'h0;
    end

    // Read.BTA1 - wait for master to stop driving bus
    @(negedge clk_out) begin
        txe_n <= 1'b1;
    end

    // Read.BTA2 - start driving bus
    @(negedge clk_out) begin
        data_out[31:0] <= 32'hFFFFFFFF;
        data_oe[31:0] <= 32'hFFFFFFFF;
        be_oe[3:0] <= 4'hF;
    end

    // Read.SendData
    repeat(1024) begin
        @(negedge clk_out) begin
            data_out <= data_out + 1;
            be_out <= 4'hF;
            rxf_n <= 1'b0;
        end
    end

    // Read.ReverseBTA - stop driving bus
    @(negedge clk_out) begin
        data_oe[31:0] <= 32'h0000FF00;
        be_oe[3:0] <= 4'hF;
        rxf_n <= 1'b1;
    end

    // Idle
    @(negedge clk_out) begin
        txe_n <= 1'b0;
    end
*/
    repeat (100) @(negedge clk_out);
  //  $finish();

end


// ch_if_ prefix indicates interface-side signals between FT601 and FPGA
// ch_pc_ prefix indicates USB-side signals between FT601 and PC

wire [31:0] ch_if_rd_data [1:4];
wire [31:0] ch_if_rd_be [1:4];
wire ch_if_rd_en [1:4];
wire ch_if_rd_empty [1:4];


wire [31:0] ch_if_wr_data [1:4];
wire [31:0] ch_if_wr_be [1:4];
wire ch_if_wr_en [1:4];
wire ch_if_wr_full [1:4];




wire [31:0] ch_pc_rd_data [1:4];
wire [31:0] ch_pc_rd_be [1:4];
wire ch_pc_rd_en [1:4];
wire ch_pc_rd_empty [1:4];


wire [31:0] ch_pc_wr_data [1:4];
wire [31:0] ch_pc_wr_be [1:4];
wire ch_pc_wr_en [1:4];
wire ch_pc_wr_full [1:4];






/*
wire ch_if_pc_tx_en [1:4];

wire ch1_pc_rx_en [1:4];


wire wr_buf_full [1:4];
wire wr_buf_empty [1:4];

wire rd_buf_full [1:4];
wire rd_buf_empty [1:4];
*/


genvar ch;
generate
for (ch = 1; ch <= 4; ch=ch+1) begin
/*
    ft601_mcfifo_wr_buf #( )
    mcfifo_channel_wr_buf (
        
       .max_packet_size(),
                 
       .wr_reset(  reset),
       .wr_clk(    clk),
       .wr_data(   {wr_be, wr_data}),
       .wr_en(     wr_valid),
       .wr_ce(     wr_buf_wr_sel == i),
       .wr_push(   wr_push),
       .writeable( wr_buf_writeable[i]),
       .almost_unwriteable(wr_buf_almost_unwriteable[i]),
       
       .rd_reset(  !locked_mmcm),
       .rd_clk(    clk0_mmcm),
       .rd_data(   wr_buf_rd_data[i]),
       .rd_valid(  wr_buf_rd_valid[i]),
       .ft_txe_n(  ft601_txe_n),
       .ft_wr_n(   ft601_wr_n),  
       .rd_ce(     wr_buf_rd_sel == i),
       .rd_empty(  wr_buf_rd_empty[i]),
       .rd_aempty( wr_buf_rd_aempty[i]),
       .readable(  wr_buf_readable[i])
   );
       
       
       
       
         
        
       input [31:0] max_packet_size, 
       
   
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
       input rd_en,    
       output rd_empty,
       output rd_aempty,
       output reg readable
       
       
       
    )


    
    xpm_fifo_async #(
    
        .CDC_SYNC_STAGES(2),       // DECIMAL
        .DOUT_RESET_VALUE("0"),    // String
        .FIFO_MEMORY_TYPE("block"), // String
        .READ_MODE("fwft"),
        .FIFO_READ_LATENCY(1),     // DECIMAL
        .FIFO_WRITE_DEPTH(2048),   // DECIMAL
        .READ_DATA_WIDTH(36),      // DECIMAL
        .WRITE_DATA_WIDTH(36),     // DECIMAL
        .PROG_FULL_THRESHOLD(1024)
    )
    ch1_read_fifo (
    
        .rst(!reset_n),   
        
        .wr_clk(clk_out),
        .din({ch1_rd_be, ch1_rd_data}),      
        .wr_en(ch1_pc_tx_en),    
        .prog_full(ch1_tx_full),
            
        .rd_clk(!clk_out),
        .dout({be_out, data_out}),  
        .rd_en(!rd_n && !rxf_n),    
        .empty(rxf_n)
    );
    
    */
end
endgenerate












    /*
    
    
//reg [31:0] data_out;
wire [31:0] data_out;
wire [31:0] data_in = data;
    
wire [3:0] be_out;// = 4'b1111;
wire [3:0] be_in = be;

// t1: clkout period
time t1 = 10.00;




localparam STATE_RESET = 0;
localparam STATE_IDLE = 1;
localparam STATE_READ = 2;
localparam STATE_WRITE = 3;

reg [1:0] state = STATE_RESET;


reg done_read = 1'b0;
reg done_write = 1'b0;



wire write_fifo_aempty;
wire write_fifo_full;



genvar i;
generate 
for (i=0; i<32; i=i+1) begin    
    IOBUF data_iobuf (
        .I(data_out[i]),
        .O(data_in[i]),
        .IO(data[i]),
        .T(oe_n)
    );    
end
for (i=0; i<4; i=i+1) begin    
    IOBUF be_iobuf (
        .I(be_out[i]),
        .O(be_in[i]),
        .IO(be[i]),
        .T(oe_n)
    );    
end
endgenerate



always #5005 begin // 100 MHz
    if (!reset_n) begin
        clk_out <= 1'b0;
    end
    else begin
        clk_out <= !clk_out;
    end
end



integer seed = 0;



wire read_fifo_re = !rd_n;

assign txe_n = write_fifo_full || !reset_n;
 
 
/////////////////////////////////////////////////////////////
//
// Read FIFO + Logic
//
/////////////////////////////////////////////////////////////

reg [31:0] pc_tx_data;
reg [3:0] pc_tx_be;
reg pc_tx_en;
wire pc_tx_full;



xpm_fifo_async #(
    .CDC_SYNC_STAGES(2),       // DECIMAL
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(36),      // DECIMAL
    .WRITE_DATA_WIDTH(36)     // DECIMAL
)
read_fifo (

    .rst(!reset_n),   
    
    .wr_clk(clk_out),
    .din({pc_tx_be, pc_tx_data}),      
    .wr_en(pc_tx_en),    
    .full(pc_tx_full),
        
    .rd_clk(!clk_out),
    .dout({be_out, data_out}),  
    .rd_en(!rd_n && !rxf_n),    
    .empty(rxf_n)
);


integer k;


// USB data source
always begin

    if (!reset_n) begin
        @(posedge clk_out) begin
            pc_tx_data <= 32'hX;
            pc_tx_be <= 4'hX;
            pc_tx_en <= 1'b0;       
        end
    end         
    
    else begin
    
        #($urandom_range(500, 500)*1us);
                
        pc_tx_be <= 4'b1000;     
        
        for (k=0; k<4096; k=k+1) begin
        
            while (pc_tx_full) @(posedge clk_out);
            
            @(posedge clk_out) begin
                pc_tx_en <= 1'b1;  
                pc_tx_data <= k; 
                pc_tx_be <= {pc_tx_be[2:0], pc_tx_be[3]};
            end
        end
        
        @(posedge clk_out) begin
            pc_tx_data <= 32'hX;
            pc_tx_en <= 1'b0;        
            pc_tx_be <= 4'hX;
        end
                    
    end
end



/////////////////////////////////////////////////////////////
//
// Write FIFO + Logic
//
/////////////////////////////////////////////////////////////

wire [31:0] wr_fifo_dout;
wire [3:0] wr_fifo_be;
wire wr_fifo_empty;

reg [31:0] pc_rx_data;
reg [3:0] pc_rx_be;
reg pc_rx_valid;


xpm_fifo_async #(
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .READ_MODE("fwft"),
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(36),      // DECIMAL
    .WRITE_DATA_WIDTH(36)     // DECIMAL
)
write_fifo (

    .rst(!reset_n),   
    
    .wr_clk(!clk_out),
    .din({be_in, data_in}),      
    .wr_en(!wr_n),    
    .full(write_fifo_full),
    
    .rd_clk(clk_out),
    .dout({wr_fifo_be, wr_fifo_dout}),
    .rd_en(!wr_fifo_empty),    
    .empty(wr_fifo_empty),
    .almost_empty(write_fifo_aempty)
);


always @(posedge clk_out) begin
    pc_rx_data <= wr_fifo_dout;
    pc_rx_be <= wr_fifo_be;
    pc_rx_valid <= !wr_fifo_empty;
end


*/

endmodule
