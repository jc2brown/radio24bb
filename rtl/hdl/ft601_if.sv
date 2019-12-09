`timescale 1ps / 1ps


/*

MultiChannel FIFO Mode:
When  the  bus  is  in the idle state DATA[31:16], DATA[7:0] and BE[3:0] are driven to logic "1" by the bus master, 
and DATA[15:8] is driven by the bus slave to provide the FIFO status to the bus master. The upper nibble (DATA[15:12]) 
provides the 4 OUT channels FIFO status while the lower nibble (DATA[11:8]) provides the 4 IN channels FIFO status. 
They are all active low.

*/


module ft601_if(

    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////
    
    input wire ft601_clkin,
    inout wire [31:0] ft601_data,
    inout wire [3:0] ft601_be,
    input wire ft601_txe_n,
    input wire ft601_rxf_n,
    output reg ft601_oe_n,
    output reg ft601_wr_n,
    output reg ft601_rd_n,
    output wire ft601_siwu_n,
//    output wire ft601_reset_n,
//    output wire ft601_wake_n,
    
    
    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////
    
    input clk,
    input reset,

    input wire [31:0] wr_data,
    input wire [3:0] wr_be,
    input wire wr_valid,
    output wire wr_fifo_full,
    
    output reg [31:0] rd_data,
    output reg [3:0] rd_be,
    input wire rd_en,
    output reg rd_valid,
    output wire rd_fifo_empty
    
);
    
    
//assign ft601_reset_n = !reset;
//assign ft601_wake_n = 1'b1;
assign ft601_siwu_n = 1'b1;
    
    
genvar i;


wire data_oe_n;

    


/////////////////////////////////////////////////////////////
//
// MMCM
//
/////////////////////////////////////////////////////////////

wire clk0_mmcm;
wire clkfb;
wire locked_mmcm = 1'b1;

assign clk0_mmcm = ft601_clkin;
/*
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
*/



/////////////////////////////////////////////////////////////
//
// Write FIFO
//
/////////////////////////////////////////////////////////////



localparam STATE_IDLE = 2'd0;
localparam STATE_BTA = 2'd1; // data bus turnaround before read
localparam STATE_READ = 2'd2;
localparam STATE_WRITE = 2'd3;

reg [1:0] state;


    
reg [31:0] wr_data_fifo;
reg [3:0] wr_be_fifo;
wire wr_fifo_rd_en;
wire wr_fifo_empty;

reg wr_n;


wire [31:0] wr_data_fifo_out;
wire [3:0] wr_be_fifo_out;

xpm_fifo_async #(
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(36),      // DECIMAL
    .WRITE_DATA_WIDTH(36)     // DECIMAL
)
write_fifo_inst (

    .rst(reset),   
    
    .wr_clk(clk),
    .din({wr_be, wr_data}),      
    .wr_en(wr_valid),    
    .full(wr_fifo_full),
    
    .rd_clk(!clk0_mmcm),
//    .dout({wr_be_fifo, wr_data_fifo}),  
    .dout({wr_be_fifo_out, wr_data_fifo_out}),  
    .rd_en(state == STATE_WRITE),
    .empty(wr_fifo_empty)
);


always @(negedge clk0_mmcm) begin

    if (state != STATE_WRITE) begin
        wr_n <= 1'b1;
//        wr_data_fifo <= 32'hX;
//        wr_be_fifo <= 4'hX;
    end
    else if (!wr_fifo_empty) begin
        wr_n <= 1'b0;
//        wr_data_fifo <= wr_data_fifo_out;
//        wr_be_fifo <= wr_be_fifo_out;
    end
    else begin 
        wr_n <= 1'b1;
//        wr_data_fifo <= 32'hX;
//        wr_be_fifo <= 4'hX;    
    end
end



//always @(negedge clk0_mmcm) begin
//    if (wr_fifo_empty) begin
//        wr_data_fifo <= 32'h00;
//        wr_be_fifo <= 4'h0;
//    end 
//    else if (!wr_n) begin
//        wr_data_fifo <= wr_data_fifo_out;
//        wr_be_fifo <= wr_be_fifo_out;
//    end
//end

always @(*) begin
    if (wr_fifo_empty) begin
        wr_data_fifo <= 32'hX;
        wr_be_fifo <= 4'hX;
    end
    else begin
        wr_data_fifo <= wr_data_fifo_out;
        wr_be_fifo <= wr_be_fifo_out;
    end
end




/////////////////////////////////////////////////////////////
//
// IO Buffers
//
/////////////////////////////////////////////////////////////

wire [31:0] data_in_iobuf;

//wire [3:0] be = 4'b1111;
wire [3:0] be_in_iobuf;
    
generate
for (i=0; i<32; i=i+1) begin
    IOBUF data_iobuf_inst (
        .IO(ft601_data[i]),
        .I(wr_data_fifo[i]),
        .O(data_in_iobuf[i]),
        .T(data_oe_n)
    );    
end
endgenerate

generate
for (i=0; i<4; i=i+1) begin
    IOBUF be_iobuf_inst (
        .IO(ft601_be[i]),
        .I(wr_be_fifo[i]),
        .O(be_in_iobuf[i]),
        .T(data_oe_n)
    );    
end
endgenerate
    
   
    

assign ft601_wr_n = wr_n || wr_fifo_empty;
        
    
    
 
/////////////////////////////////////////////////////////////
//
// Control logic
// 245 Sync FIFO Mode
//
/////////////////////////////////////////////////////////////   
    
    
wire rd_fifo_full;
    

always @(negedge clk0_mmcm) begin
	if (reset || !locked_mmcm) begin
		state <= STATE_IDLE;
	end
	else begin
		case (state) 
		STATE_IDLE: begin
			if (!ft601_rxf_n && !rd_fifo_full) begin
				state <= STATE_BTA;
			end
			else if (!ft601_txe_n && !wr_fifo_empty) begin
				state <= STATE_WRITE;
			end
		end
		STATE_BTA: begin
			if (!ft601_rxf_n && !rd_fifo_full) begin
				state <= STATE_READ;
			end 
			else begin
				state <= STATE_IDLE;
			end
		end
		STATE_READ: begin
			if (ft601_rxf_n || rd_fifo_full) begin
				state <= STATE_IDLE;
			end
		end
		STATE_WRITE: begin
                                //wr_n <= 1'b0;
			if (ft601_txe_n || wr_fifo_empty) begin
				state <= STATE_IDLE;
                        //wr_n <= 1'b1;
				
			end
		end
		endcase
	end
end



always @(*) begin
	case (state) 
	STATE_IDLE: begin
		ft601_oe_n <= 1'b1;
		ft601_rd_n <= 1'b1;
//		wr_n <= 1'b1;
	end
	STATE_BTA: begin
		ft601_oe_n <= 1'b0;
		ft601_rd_n <= 1'b1;
//		wr_n <= 1'b1;
	end
	STATE_READ: begin
		ft601_oe_n <= 1'b0;
		ft601_rd_n <= 1'b0;
//		wr_n <= 1'b1;
	end
	STATE_WRITE: begin
		ft601_oe_n <= 1'b1;
		ft601_rd_n <= 1'b1;
		//wr_n <= 1'b0;
	end
    endcase
end


assign data_oe_n = (state == STATE_BTA || state == STATE_READ);


 
    
/////////////////////////////////////////////////////////////
//
// Read FIFO
//
/////////////////////////////////////////////////////////////

wire [31:0] rd_fifo_data_out;
wire [3:0] rd_fifo_be_out;


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
read_fifo_inst (

    .rst(reset),   
    
    .wr_clk(clk0_mmcm),
    .din({be_in_iobuf, data_in_iobuf}),      
    .wr_en(!ft601_rd_n),    
    .full(rd_fifo_full),
    
    .rd_clk(clk),
    .dout({rd_fifo_be_out, rd_fifo_data_out}),  
//    .dout(rd_data),  
    .rd_en(rd_en),    
    .empty(rd_fifo_empty)
);

reg rd_en_d1;

always @(posedge clk) begin
    rd_data <= rd_fifo_data_out;
    rd_be <= rd_fifo_be_out;
    rd_en_d1 <= rd_en && !rd_fifo_empty;    
end



always @(*) begin
    rd_valid <= rd_en_d1 && !rd_fifo_empty;    
end

    
    
endmodule
