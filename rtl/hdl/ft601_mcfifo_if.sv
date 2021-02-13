`timescale 1ps / 1ps

/*
MultiChannel FIFO Mode:
When  the  bus  is  in the idle state DATA[31:16], DATA[7:0] and BE[3:0] are driven to logic "1" by the bus master, 
and DATA[15:8] is driven by the bus slave to provide the FIFO status to the bus master. The upper nibble (DATA[15:12]) 
provides the 4 OUT channels FIFO status while the lower nibble (DATA[11:8]) provides the 4 IN channels FIFO status. 
They are all active low.

FIFO OUT is for data transmitted from USB host to device
The upper nibble (DATA[15:12]) provides the 4 OUT channels FIFO status

DATA[8]:  channel 1 FIFO to PC: 0=can write packet  1=full
DATA[9]:  channel 2 FIFO to PC: 0=can write packet  1=full
DATA[10]: channel 3 FIFO to PC: 0=can write packet  1=full
DATA[11]: channel 4 FIFO to PC: 0=can write packet  1=full

DATA[12]: channel 1 FIFO from PC: 0=can read data  1=empty
DATA[13]: channel 2 FIFO from PC: 0=can read data  1=empty
DATA[14]: channel 3 FIFO from PC: 0=can read data  1=empty
DATA[15]: channel 4 FIFO from PC: 0=can read data  1=empty

Command Phase     FT601Command    Channel Address 
                  BE[3:0]         DATA[7:0]  

Master Read       0000            8'h1=Channel 1
                                  8'h2=Channel 2
Master Write      0001            8'h3=Channel 3
                                  8'h4=Channel 4
*/

module ft601_mcfifo_if 
#(
    parameter NUM_CHANNELS = 4, // 1, 2, or 4
    parameter MAX_PACKET_SIZE = 1024
)
(

    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////
    
    input wire          ft601_clkin,
    inout wire [31:0]   ft601_data,
    inout wire [3:0]    ft601_be,
    (* mark_debug = "true" *) input wire          ft601_txe_n,
    (* mark_debug = "true" *) input wire          ft601_rxf_n,
    (* mark_debug = "true" *) output reg          ft601_oe_n,
    (* mark_debug = "true" *) output reg          ft601_wr_n,
    (* mark_debug = "true" *) output reg          ft601_rd_n,
    output wire         ft601_siwu_n,
    
   
    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////
    
    input clk,
    input reset,
    
    output locked,

    input wire [31:0]   wr_ch_wr_data             [NUM_CHANNELS:1],
    input wire [3:0]    wr_ch_wr_be               [NUM_CHANNELS:1],
    input wire          wr_ch_wr_en               [NUM_CHANNELS:1],
    input wire          wr_ch_wr_push             [NUM_CHANNELS:1],
    
    output wire         wr_ch_wr_full             [NUM_CHANNELS:1],
    output wire         wr_ch_wr_almost_full      [NUM_CHANNELS:1],
    output wire         wr_ch_has_wr_packet_space [NUM_CHANNELS:1],
    
    
    output reg [31:0]   rd_ch_rd_data             [NUM_CHANNELS:1],
    output reg [3:0]    rd_ch_rd_be               [NUM_CHANNELS:1],
    input wire          rd_ch_rd_en               [NUM_CHANNELS:1],
    output reg          rd_ch_rd_valid            [NUM_CHANNELS:1],
    
    output wire         rd_ch_rd_empty            [NUM_CHANNELS:1],
    output wire         rd_ch_rd_almost_empty     [NUM_CHANNELS:1]
    
);



always @(*) begin
    ft601_oe_n <= 1'b1;
    ft601_rd_n <= 1'b1;
end
    
    
    
localparam STATE_RESET                  = 4'd0;

localparam STATE_IDLE                   = 4'd1;
localparam STATE_MAYBE_START_READ       = 4'd2;
localparam STATE_MAYBE_START_WRITE      = 4'd3;

localparam STATE_READ_COMMAND           = 4'd4;
localparam STATE_READ_BTA1              = 4'd5;
localparam STATE_READ_BTA2              = 4'd6;
localparam STATE_READ_DATA              = 4'd7;
localparam STATE_READ_BTA3              = 4'd8;

localparam STATE_WRITE_COMMAND          = 4'd9;
localparam STATE_WRITE_BTA1             = 4'd10;
localparam STATE_WRITE_DATA             = 4'd11;
localparam STATE_WRITE_BTA2             = 4'd12;

localparam STATE_NEXT_CHANNEL           = 4'd13;
    
    

wire clk0_mmcm;
wire clkfb;
wire locked_mmcm;

    
(* mark_debug = "true" *) wire [31:0] data_in;

(* mark_debug = "true" *) reg [3:0] be_out;
(* mark_debug = "true" *) wire [3:0] be_in;

(* mark_debug = "true" *) reg [31:0] data_oe_n;
(* mark_debug = "true" *) reg [3:0] be_oe_n;



(* mark_debug = "true" *) reg cmd_mux; // 0=normal data, 1=cmd data
(* mark_debug = "true" *) reg [31:0] cmd_data;
(* mark_debug = "true" *) reg [3:0] cmd_be;

(* mark_debug = "true" *) reg [2:0] channel;


(* mark_debug = "true" *) wire [31:0] data_out;

(* mark_debug = "true" *) wire [31:0] wr_ch_rd_data [NUM_CHANNELS:1];
(* mark_debug = "true" *) wire [3:0] wr_ch_rd_be [NUM_CHANNELS:1];
(* mark_debug = "true" *) wire wr_ch_rd_en [NUM_CHANNELS:1];


(* mark_debug = "true" *) wire wr_ch_rd_valid [NUM_CHANNELS:1];

(* mark_debug = "true" *) wire wr_ch_rd_xfer_req [NUM_CHANNELS:1];
(* mark_debug = "true" *) wire wr_ch_rd_xfer_done [NUM_CHANNELS:1];
(* mark_debug = "true" *) wire wr_ch_rd_xfer_almost_done [NUM_CHANNELS:1];


(* mark_debug = "true" *) reg [3:0] state;


wire rd_ch_wr_en [NUM_CHANNELS:1];

wire rd_ch_wr_full [NUM_CHANNELS:1];
wire rd_ch_wr_almost_full [NUM_CHANNELS:1];
wire rd_ch_has_wr_packet_space [NUM_CHANNELS:1];

(* mark_debug = "true" *) wire can_write [4:1];
(* mark_debug = "true" *) wire can_read [4:1];
reg [31:0] reset_count;



assign ft601_siwu_n = 1'b1;


assign data_out =   (state == STATE_WRITE_DATA && channel == 1) ? wr_ch_rd_data[1] : 
                    (state == STATE_WRITE_DATA && channel == 2) ? wr_ch_rd_data[2] : 
                    (state == STATE_WRITE_DATA && channel == 3) ? wr_ch_rd_data[3] : 
                    (state == STATE_WRITE_DATA && channel == 4) ? wr_ch_rd_data[4] : 
                    0;


assign be_out =     (state == STATE_WRITE_DATA && channel == 1) ? wr_ch_rd_be[1] : 
                    (state == STATE_WRITE_DATA && channel == 2) ? wr_ch_rd_be[2] : 
                    (state == STATE_WRITE_DATA && channel == 3) ? wr_ch_rd_be[3] : 
                    (state == STATE_WRITE_DATA && channel == 4) ? wr_ch_rd_be[4] : 
                    0;


assign wr_ch_rd_en[1] = (channel == 1) && /*!ft601_rxf_n && */!ft601_wr_n && (state == STATE_WRITE_DATA);
assign wr_ch_rd_en[2] = (channel == 2) && /*!ft601_rxf_n && */!ft601_wr_n && (state == STATE_WRITE_DATA);
assign wr_ch_rd_en[3] = (channel == 3) && /*!ft601_rxf_n && */!ft601_wr_n && (state == STATE_WRITE_DATA);
assign wr_ch_rd_en[4] = (channel == 4) && /*!ft601_rxf_n && */!ft601_wr_n && (state == STATE_WRITE_DATA);


assign rd_ch_wr_en[1] = (channel == 1) && !ft601_rxf_n && !ft601_wr_n && (state == STATE_READ_DATA);
assign rd_ch_wr_en[2] = (channel == 2) && !ft601_rxf_n && !ft601_wr_n && (state == STATE_READ_DATA);
assign rd_ch_wr_en[3] = (channel == 3) && !ft601_rxf_n && !ft601_wr_n && (state == STATE_READ_DATA);
assign rd_ch_wr_en[4] = (channel == 4) && !ft601_rxf_n && !ft601_wr_n && (state == STATE_READ_DATA);

assign can_write[1] = (state == STATE_MAYBE_START_WRITE) && !data_in[8];
assign can_write[2] = (state == STATE_MAYBE_START_WRITE) && !data_in[9];
assign can_write[3] = (state == STATE_MAYBE_START_WRITE) && !data_in[10];
assign can_write[4] = (state == STATE_MAYBE_START_WRITE) && !data_in[11];

assign can_read[1] = (state == STATE_MAYBE_START_READ) && !data_in[12];
assign can_read[2] = (state == STATE_MAYBE_START_READ) && !data_in[13];
assign can_read[3] = (state == STATE_MAYBE_START_READ) && !data_in[14];
assign can_read[4] = (state == STATE_MAYBE_START_READ) && !data_in[15];



/////////////////////////////////////////////////////////////
//
// IO Buffers
//
/////////////////////////////////////////////////////////////


IOBUF data_iobuf_inst [31:0] (
    .IO(ft601_data),
    .I( cmd_mux ? cmd_data : data_out  ),
    .O(data_in),
    .T(data_oe_n)
);    


IOBUF be_iobuf_inst [3:0] (
    .IO(ft601_be),
    .I( cmd_mux ? cmd_be : be_out ),
    .O(be_in),
    .T(be_oe_n)
);   
    
    

/////////////////////////////////////////////////////////////
//
// MMCM
//
/////////////////////////////////////////////////////////////


xpm_cdc_async_rst xpm_cdc_async_rst_inst (
    .dest_arst(locked), 
    .dest_clk(clk),  
    .src_arst(locked_mmcm) 
);
   
   

MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKFBOUT_MULT_F(8.0),  // fVCO=800MHz
    .CLKFBOUT_PHASE(0.0),
    .CLKIN1_PERIOD(10.0),   // fIN=100MHz
    .CLKOUT0_DIVIDE_F(8.0), // fOUT=100MHz
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),
    .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
    .DIVCLK_DIVIDE(1),         // Master division value (1-106)
    .REF_JITTER1(0.01),         // Reference input jitter in UI (0.000-0.999).
    .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
)
MMCME2_BASE_inst 
(
    .CLKIN1(ft601_clkin),       // 1-bit input: Clock
    .CLKOUT0(clk0_mmcm),     // 1-bit output: CLKOUT0
    
    .CLKFBOUT(clkfb),   // 1-bit output: Feedback clock
    .CLKFBIN(clkfb),      // 1-bit input: Feedback clock
    
    .LOCKED(locked_mmcm),       // 1-bit output: LOCK
    
    .PWRDWN(1'b0),       // 1-bit input: Power-down
    .RST(reset)             // 1-bit input: Reset
);



/////////////////////////////////////////////////////////////
//
// Write FIFO
//
/////////////////////////////////////////////////////////////


ft601_mcfifo_wr_buf 
#(
    .CAPACITY(2**14), // bytes 
    .MAX_PACKET_SIZE(MAX_PACKET_SIZE)
)
wr_buf [NUM_CHANNELS:1] 
(
    
    .wr_reset(reset || !locked),
    .wr_clk(clk),
    
    .wr_data(wr_ch_wr_data),
    .wr_be(wr_ch_wr_be),
    .wr_en(wr_ch_wr_en),
    .wr_push(wr_ch_wr_push),
    
    .wr_full(wr_ch_wr_full),
    .wr_almost_full(wr_ch_wr_almost_full),
    .wr_has_packet_space(wr_ch_has_wr_packet_space), // Asserted when a device can write at least an entire packet's worth of data without the buffer becoming full
            
    .rd_reset(!locked_mmcm),
    .rd_clk(!clk0_mmcm), // negedge per IF spec
    
    .rd_data(wr_ch_rd_data),
    .rd_be(wr_ch_rd_be),
    .rd_valid(wr_ch_rd_valid),
    .rd_en(wr_ch_rd_en),    
    
    .rd_xfer_done(wr_ch_rd_xfer_done),
    .rd_xfer_almost_done(wr_ch_rd_xfer_almost_done),
    .rd_xfer_req(wr_ch_rd_xfer_req)

);


/////////////////////////////////////////////////////////////
//
// Read FIFO
//
/////////////////////////////////////////////////////////////


ft601_mcfifo_rd_buf 
#(
    .CAPACITY(2**14), // bytes 
    .MAX_PACKET_SIZE(MAX_PACKET_SIZE)
)
rd_buf [NUM_CHANNELS:1]
(
           
    .wr_reset(!locked_mmcm),
    .wr_clk(clk0_mmcm), // posedge to sample data in middle of stable region
    .wr_data(data_in),
    .wr_be(be_in),
    .wr_en(rd_ch_wr_en),
    
    .wr_full(rd_ch_wr_full),
    .wr_almost_full(rd_ch_wr_almost_full),
    .wr_has_packet_space(rd_ch_has_wr_packet_space),
    
    .rd_reset(reset || !locked),
    .rd_clk(clk),
    .rd_data(rd_ch_rd_data),
    .rd_be(rd_ch_rd_be),
    .rd_valid(rd_ch_rd_valid),
    .rd_en(rd_ch_rd_en),
    .rd_empty(rd_ch_rd_empty),
    .rd_almost_empty(rd_ch_rd_almost_empty)
    
);

reg [31:0] rd_count;
reg [31:0] wr_count;



always @(negedge clk0_mmcm, negedge locked_mmcm) begin

    if (!locked_mmcm) begin
        reset_count <= 0;
        channel <= 1;
        ft601_wr_n <= 1'b1;
        cmd_mux <= 1'b0;
        cmd_data <= 32'h00000000;
        cmd_be <= 4'h0; 
        data_oe_n <= 32'h0000FF00;
        be_oe_n <= 4'h0;      
        
        rd_count <= 0;
        wr_count <= 0;
        
        state <= STATE_RESET;             
    end
    else begin
    
        // Wait some cycles while the FIFOs exit reset
        if (state == STATE_RESET) begin
            if (reset_count == 100) begin        
                state <= STATE_IDLE;
            end
            else begin
                reset_count <= reset_count + 1;
            end     
        end
        
        
        else if (state == STATE_IDLE) begin        
            state <= STATE_MAYBE_START_READ;        
        end
        
        else if (state == STATE_MAYBE_START_READ) begin
            
            // Reasons why we can't read the current channel
            if ( !can_read[channel] || !rd_ch_has_wr_packet_space[channel] ) begin                
                state <= STATE_MAYBE_START_WRITE;
            end
        
            else begin               
            
                rd_count <= 0;
                 
                ft601_wr_n <= 1'b0;
                cmd_mux <= 1'b1;
                cmd_data <= {28'h0000000, channel};
                cmd_be <= 4'h0; // Read command
                data_oe_n <= 32'h0000FF00;
                be_oe_n <= 4'h0;   
                state <= STATE_READ_COMMAND;
            end
        end
        

        else if (state == STATE_READ_COMMAND) begin
            cmd_mux <= 1'b0;        
            data_oe_n <= 32'h0000FF00;
            be_oe_n <= 4'h0;            
            state <= STATE_READ_BTA1;
        end
        
        
        else if (state == STATE_READ_BTA1) begin        
            data_oe_n <= 32'hFFFFFFFF;
            be_oe_n <= 4'hF;                    
            state <= STATE_READ_BTA2;
        end
        
        
        else if (state == STATE_READ_BTA2) begin
            state <= STATE_READ_DATA;
        end

        
        else if (state == STATE_READ_DATA) begin
            if (!ft601_wr_n && !ft601_rxf_n) begin
                rd_count <= rd_count + 1;
            end
            if (ft601_rxf_n || rd_ch_wr_almost_full[channel]) begin
                ft601_wr_n <= 1'b1;
                state <= STATE_READ_BTA3;
            end
        end
        
        
        else if (state == STATE_READ_BTA3) begin        
            data_oe_n <= 32'h0000FF00;
            be_oe_n <= 4'h0;               
                       
            $display("FPGA RECV'D %0d WORDS FROM CHANNEL %0d", rd_count, channel);     
                         
            state <= STATE_MAYBE_START_WRITE;
        end
        
        
        
        
        else if (state == STATE_MAYBE_START_WRITE) begin
        
           // Reasons we can't write the current channel
           if ( !can_write[channel] || !wr_ch_rd_xfer_req[channel] ) begin          
               state <= STATE_NEXT_CHANNEL;
//               channel <= (channel == NUM_CHANNELS) ? 1 : (channel + 1);
//               state <= STATE_MAYBE_START_READ;
           end
       
           else begin     
                       
                       
               /* HACK FOR DEBUG - txe_n needs a load */        
               if (!ft601_txe_n) begin
               
                   
                   wr_count <= 0;  
                       
                   ft601_wr_n <= 1'b0;
                   cmd_mux <= 1'b1;
                   cmd_data <= {28'h0000000, channel};
                   data_oe_n <= 32'h0000FF00;
                   cmd_be <= 4'h1; // Write command
                   be_oe_n <= 4'h0;           
                   state <= STATE_WRITE_COMMAND;
           
                end
           
           end
                   
        end
        
       
        else if (state == STATE_WRITE_COMMAND) begin
            state <= STATE_WRITE_BTA1;
        end
        

        else if (state == STATE_WRITE_BTA1) begin
            //if (ft601_txe_n) begin
                cmd_mux <= 1'b0;
                data_oe_n <= 32'h00000000;
                state <= STATE_WRITE_DATA;
           //end
        end
        

        else if (state == STATE_WRITE_DATA) begin
        
            if (!ft601_wr_n/* && !ft601_rxf_n*/) begin
                wr_count <= wr_count + 1;
            end
        
            if (/*ft601_rxf_n || */wr_ch_rd_xfer_almost_done[channel]) begin
                ft601_wr_n <= 1'b1;
                state <= STATE_WRITE_BTA2;
            end
        end
        
        
        else if (state == STATE_WRITE_BTA2) begin
            data_oe_n <= 32'h0000FF00;
            
            $display("FPGA WROTE %0d WORDS TO CHANNEL %0d", wr_count, channel);     
                           
            state <= STATE_NEXT_CHANNEL;
//            channel <= (channel == NUM_CHANNELS) ? 1 : (channel + 1);
//            state <= STATE_MAYBE_START_READ;
        end
        
        
//         Elminating this state to improve bus efficiency
        else if (state == STATE_NEXT_CHANNEL) begin
            channel <= (channel == NUM_CHANNELS) ? 1 : (channel + 1);
            state <= STATE_MAYBE_START_READ;
        end
        
    end

end



 
    
endmodule
