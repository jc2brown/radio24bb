`timescale 1ps / 1ps


module tb_ft601_mcfifo();
    
    
localparam NUM_CHANNELS = 4;    
localparam MAX_PACKET_SIZE = 1024;    


reg reset_n = 0;
wire clk_out;
wire [31:0] data;
wire [3:0] be;
wire oe_n;
wire wr_n;
wire rd_n;
wire txe_n;
wire rxf_n;
wire siwu_n;
        


ft601_mcfifo 
#(
    .NUM_CHANNELS(NUM_CHANNELS),
    .MAX_PACKET_SIZE(MAX_PACKET_SIZE)
)
ft601
(
    .reset_n(reset_n),
    .clk_out(clk_out),
    .data(data),    
    .be(be),       
    .oe_n(oe_n),   
    .wr_n(wr_n),    
    .rd_n(rd_n),    
    .txe_n(txe_n),  
    .rxf_n(rxf_n),  
    .siwu_n(siwu_n)      
);




reg clk = 0;
always #5005 clk <= !clk; // Slightly slower than 100MHz

reg reset = 1;
initial #50000 reset <= 0;


wire locked;

wire [31:0]   wr_ch_wr_data             [NUM_CHANNELS:1];
wire [3:0]    wr_ch_wr_be               [NUM_CHANNELS:1];
wire          wr_ch_wr_en               [NUM_CHANNELS:1];
wire          wr_ch_wr_push             [NUM_CHANNELS:1];

wire         wr_ch_wr_full              [NUM_CHANNELS:1];
wire         wr_ch_wr_almost_full       [NUM_CHANNELS:1];
wire         wr_ch_has_wr_packet_space  [NUM_CHANNELS:1];


wire [31:0]   rd_ch_rd_data             [NUM_CHANNELS:1];
wire [3:0]    rd_ch_rd_be               [NUM_CHANNELS:1];
wire           rd_ch_rd_en               [NUM_CHANNELS:1];
wire          rd_ch_rd_valid            [NUM_CHANNELS:1];

wire         rd_ch_rd_empty             [NUM_CHANNELS:1];
wire         rd_ch_rd_almost_empty      [NUM_CHANNELS:1];

    
    

ft601_mcfifo_if #( 
    .NUM_CHANNELS(NUM_CHANNELS),
    .MAX_PACKET_SIZE(MAX_PACKET_SIZE)
) dut (

    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////
    
    .ft601_clkin(clk_out),
    .ft601_data(data),    
    .ft601_be(be),       
    .ft601_oe_n(oe_n),   
    .ft601_wr_n(wr_n),    
    .ft601_rd_n(rd_n),    
    .ft601_txe_n(txe_n),  
    .ft601_rxf_n(rxf_n),  
    .ft601_siwu_n(siwu_n),
    
   
    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////
    
    .clk(clk),
    .reset(reset),
    
    .locked(locked),

    .wr_ch_wr_data(wr_ch_wr_data) ,
    .wr_ch_wr_be(wr_ch_wr_be),
    .wr_ch_wr_en(wr_ch_wr_en),
    .wr_ch_wr_push(wr_ch_wr_push),
                                 
    .wr_ch_wr_full(wr_ch_wr_full),
    .wr_ch_wr_almost_full(wr_ch_wr_almost_full),
    .wr_ch_has_wr_packet_space(wr_ch_has_wr_packet_space),
                                 
                                 
    .rd_ch_rd_data(rd_ch_rd_data),
    .rd_ch_rd_be(rd_ch_rd_be),
    .rd_ch_rd_en(rd_ch_rd_en),
    .rd_ch_rd_valid(rd_ch_rd_valid),
                                 
    .rd_ch_rd_empty(rd_ch_rd_empty),
    .rd_ch_rd_almost_empty(rd_ch_rd_almost_empty)
);
    
    
initial begin

    #50000;
    @(posedge clk) reset_n <= 1;

end
    
    
    
    
    
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
        .clk(clk), // posedge within system domain
        
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
        .clk(clk), // posedge within system domain
        
        .pc_rx_data(rd_ch_rd_data[i]),
        .pc_rx_be(rd_ch_rd_be[i]),
        .pc_rx_rd_en(rd_ch_rd_en[i]),
        .pc_rx_valid(rd_ch_rd_valid[i]),
        
        .pc_rx_empty(rd_ch_rd_empty[i])
                  
    );
        
    
end
endgenerate



    
    
endmodule
