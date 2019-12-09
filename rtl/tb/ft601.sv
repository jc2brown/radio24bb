`timescale 1ps / 1ps


module ft601(

    input wire reset_n,

    output reg clk_out,
    inout wire [31:0] data,    
    inout wire [3:0] be,    
    input wire oe_n,
    input wire wr_n,
    input wire rd_n,
    output reg txe_n,
    output wire rxf_n,
    input wire siwu_n
    
);
    
    
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


reg read_fifo_we;


reg write_fifo_wr_en = 1'b0;
reg write_fifo_rd_en = 1'b0;
//reg [31:0] write_fifo_data_in;
wire write_fifo_empty;
wire write_fifo_aempty;
wire write_fifo_full;
wire write_fifo_afull;



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





wire read_fifo_afull;

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

wire [31:0] rd_fifo_dout;



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
//    .dout(rd_fifo_dout),  
    .dout({be_out, data_out}),  
    .rd_en(!rd_n && !rxf_n),    
    .empty(rxf_n)
);




//always @(posedge clk_out) begin
//    data_out <= rd_fifo_dout;
//end



//reg [31:0] usb_write_data = 32'hZZZZZZZZ;
//reg usb_write_data_valid;


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
    
        #($urandom_range(60, 60)*1us);
        
        
        pc_tx_be <= 4'b1000;     
        
        for (k=0; k<4096; k=k+1) begin
        
            while (pc_tx_full) @(posedge clk_out);
            
            @(posedge clk_out) begin
                pc_tx_en <= 1'b1;  
                pc_tx_data <= k+1; 
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
//    .dout(pc_rx_data),
    .rd_en(!wr_fifo_empty),    
    .empty(wr_fifo_empty),
    .almost_empty(write_fifo_aempty)
);


always @(posedge clk_out) begin
//always @(*) begin
    pc_rx_data <= wr_fifo_dout;
    pc_rx_be <= wr_fifo_be;
    pc_rx_valid <= !wr_fifo_empty;
end



/*
reg [31:0] usb_read_data = 32'hZZZZZZZZ;
reg [3:0] usb_read_be = 4'hZ;
reg usb_read_data_valid;
integer j;
// USB data source
initial begin

    forever begin
        
        #($urandom_range(10, 100)*1us);
    
        if (reset_n) begin
        
            
            usb_read_data <= 32'h00;
            usb_read_be <= 4'b1000;
            
            for (j=0; j<4096; j=j+1) begin
                @(posedge clk_out) begin
                    read_fifo_we <= 1'b1;  
                    usb_read_data <= j+1; 
                    usb_read_be <= {usb_read_be[2:0], usb_read_be[3]};
                    
                end
            end
            @(posedge clk_out) begin
                usb_read_data <= 32'hZZZZZZZZ;
                usb_read_be <= 4'h0;
                read_fifo_we <= 1'b0;        
            end
        end
        
    end
end
*/




endmodule
