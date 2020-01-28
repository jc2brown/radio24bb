`timescale 1ps / 1ps


module tb_ft601_mcfifo();
    
localparam NUM_CHANNELS = 4;    

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
        


ft601_mcfifo ft601 (
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
always #5000 clk <= !clk;

reg reset = 1;
initial #50000 reset <= 0;


wire locked;

reg [31:0]   wr_ch_wr_data             [1:NUM_CHANNELS];
reg [3:0]    wr_ch_wr_be               [1:NUM_CHANNELS];
reg          wr_ch_wr_en               [1:NUM_CHANNELS];
reg          wr_ch_wr_push             [1:NUM_CHANNELS];

wire         wr_ch_wr_full              [1:NUM_CHANNELS];
wire         wr_ch_wr_almost_full       [1:NUM_CHANNELS];
wire         wr_ch_has_wr_packet_space  [1:NUM_CHANNELS];


wire [31:0]   rd_ch_rd_data             [1:NUM_CHANNELS];
wire [3:0]    rd_ch_rd_be               [1:NUM_CHANNELS];
reg           rd_ch_rd_en               [1:NUM_CHANNELS];
wire          rd_ch_rd_valid            [1:NUM_CHANNELS];

wire         rd_ch_rd_empty             [1:NUM_CHANNELS];
wire         rd_ch_rd_almost_empty      [1:NUM_CHANNELS];

    
    

ft601_mcfifo_if #( 
    .NUM_CHANNELS(NUM_CHANNELS),
    .MAX_PACKET_SIZE(1024)
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
    
    
integer i;
initial begin
    
    for (i=1; i<=NUM_CHANNELS; i=i+1) begin
        wr_ch_wr_data[i] <= 0;
        wr_ch_wr_be[i] <= 0;
        wr_ch_wr_en[i] <= 0;
        wr_ch_wr_push[i] <= 0;
        
        rd_ch_rd_en[i] <= 0;
    end



    #50000;
    @(posedge clk) begin
        reset_n <= 1;
    end




end
    
    
    
endmodule
