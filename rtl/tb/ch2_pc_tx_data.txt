
module ft601_if2(

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
    input wire wr_push,
    output wire wr_full,
    
    output reg [31:0] rd_data,
    output reg [3:0] rd_be,
    input wire rd_en,
    output reg rd_valid,
    output wire rd_empty,
    
    output locked
    
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
wire locked_mmcm;// = 1'b1;

//assign locked = locked_mmcm;



xpm_cdc_async_rst xpm_cdc_async_rst_inst (
    .dest_arst(locked), 
    .dest_clk(clk),  
    .src_arst(locked_mmcm) 
);
   
   
   
   

//assign clk0_mmcm = ft601_clkin;

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
// Read/write buffers
//
/////////////////////////////////////////////////////////////

    

localparam N = 3; // Number of read/write buffers


wire [35:0] wr_buf_rd_data [0:N];
assign wr_buf_rd_data[0] = 0;

wire wr_buf_rd_valid [0:N];
assign wr_buf_rd_valid[0] = 0;

wire wr_buf_rd_empty [0:N];
assign wr_buf_rd_empty[0] = 1;

wire wr_buf_rd_aempty [0:N];
assign wr_buf_rd_aempty[0] = 0;

wire wr_buf_readable [0:N];
assign wr_buf_readable[0] = 0;

wire wr_buf_writeable [0:N];
assign wr_buf_writeable[0] = 1;

wire wr_buf_almost_unwriteable [0:N];
assign wr_buf_almost_unwriteable[0] = 1;


reg [1:0] wr_buf_wr_sel;
reg [1:0] wr_buf_wr_next;

reg [1:0] wr_buf_rd_sel;
reg [1:0] wr_buf_rd_next;


reg [1:0] rd_buf_wr_sel;
reg [1:0] rd_buf_wr_next;

reg [1:0] rd_buf_rd_sel;
reg [1:0] rd_buf_rd_next;


wire [35:0] rd_buf_rd_data [0:N];
assign rd_buf_rd_data[0] = 0;

wire rd_buf_rd_valid [0:N];
assign rd_buf_rd_valid[0] = 0;

wire rd_buf_rd_empty [0:N];
assign rd_buf_rd_empty[0] = 1;

wire rd_buf_rd_aempty [0:N];
assign rd_buf_rd_aempty[0] = 0;

wire rd_buf_readable [0:N];
assign rd_buf_readable[0] = 0;

wire rd_buf_wr_full [0:N];
assign rd_buf_wr_full[0] = 0;

wire rd_buf_almost_unwriteable [0:N];
assign rd_buf_almost_unwriteable[0] = 0;

wire rd_buf_writeable [0:N];
assign rd_buf_writeable[0] = 0;


        
wire [35:0] rd_buf_wr_data;
      
assign wr_full = !wr_buf_writeable[wr_buf_wr_sel] && !wr_buf_writeable[wr_buf_wr_next];      
      
assign rd_data = rd_buf_rd_data[rd_buf_rd_sel][31:0];
assign rd_be = rd_buf_rd_data[rd_buf_rd_sel][35:32];

reg [1:0] rd_buf_rd_sel_d1;
always @(posedge clk) rd_buf_rd_sel_d1 <= rd_buf_rd_sel;

assign rd_valid = rd_buf_rd_valid[rd_buf_rd_sel_d1];

assign rd_empty = rd_buf_rd_empty[rd_buf_rd_sel];

assign ft601_wr_n = wr_buf_rd_empty[wr_buf_rd_sel];


generate 
for (i=1; i<=N; i=i+1) begin
 
    ft601_wr_buf #( .N(i) )
    wr_buf (    
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
    
    
    ft601_rd_buf #( .N(i) )
    rd_buf (    
    
        .rd_reset(  reset),
        .rd_clk(    clk),
        .rd_data(   rd_buf_rd_data[i]),
        .rd_valid(  rd_buf_rd_valid[i]),
        .rd_en(     rd_en),
        .rd_ce(     rd_buf_rd_sel == i),
        .rd_empty(  rd_buf_rd_empty[i]),
        .rd_aempty( rd_buf_rd_aempty[i]),
        .readable(  rd_buf_readable[i]),
        
        .wr_reset(  !locked_mmcm),
        .wr_clk(    clk0_mmcm),  
        .wr_data(   rd_buf_wr_data),  
        .ft_rxf_n(  ft601_rxf_n),
        .ft_rd_n(   ft601_rd_n),      
        .wr_ce(     rd_buf_wr_sel == i),
        .wr_full(   rd_buf_wr_full[i]),
        .writeable( rd_buf_writeable[i]),
        .almost_unwriteable(rd_buf_almost_unwriteable[i])
            
    );
        
end
endgenerate



localparam STATE_IDLE = 2'd0;
localparam STATE_BTA = 2'd1; // data bus turnaround before read
localparam STATE_READ = 2'd2;
localparam STATE_WRITE = 2'd3;

reg [1:0] state;




reg do_read_next;
wire do_write_next = !do_read_next;

wire start_read = (state == STATE_IDLE) && do_read_next && !ft601_rxf_n && rd_buf_writeable[rd_buf_wr_next];
wire done_read = (state == STATE_READ) && (ft601_rxf_n || rd_buf_almost_unwriteable[rd_buf_wr_sel]);

wire start_write = (state == STATE_IDLE) && do_write_next && !ft601_txe_n && wr_buf_readable[wr_buf_rd_next];
wire done_write = (state == STATE_WRITE) && (ft601_txe_n || wr_buf_rd_aempty[wr_buf_rd_sel]);


always @(negedge clk0_mmcm) begin
    if (reset) begin
        wr_buf_rd_sel <= 0;
        wr_buf_rd_next <= 1;
    end
    else begin
        if (start_write) begin
            wr_buf_rd_sel <= wr_buf_rd_next; 
            wr_buf_rd_next <= (wr_buf_rd_next == N) ? 1 : (wr_buf_rd_next + 1);              
        end
        else if (done_write) begin
            wr_buf_rd_sel <= 0;
        end
    end    
end


always @(negedge clk0_mmcm) begin
    if (reset) begin
        rd_buf_wr_sel <= 0;
        rd_buf_wr_next <= 1;
    end
    else begin
        if (start_read) begin
            rd_buf_wr_sel <= rd_buf_wr_next;
            rd_buf_wr_next <= (rd_buf_wr_next == N) ? 1 : (rd_buf_wr_next + 1);                
        end
        else if (done_read) begin
            rd_buf_wr_sel <= 0;
        end
    end    
end



always @(posedge clk) begin
    if (reset) begin
        wr_buf_wr_sel <= 1;
        wr_buf_wr_next <= (N == 1) ? 1 : 2;
    end
    else begin
        if ((wr_valid && wr_buf_almost_unwriteable[wr_buf_wr_sel]) || wr_push) begin
            wr_buf_wr_sel <= wr_buf_wr_next;
            wr_buf_wr_next <= (wr_buf_wr_next == N) ? 1 : (wr_buf_wr_next + 1);        
        end  
    end    
end


always @(posedge clk) begin
    if (reset) begin
        rd_buf_rd_sel <= 1;
        rd_buf_rd_next <= (N == 1) ? 1 : 2;
    end
    else begin
        if (rd_en && rd_buf_readable[rd_buf_rd_sel] && rd_buf_rd_aempty[rd_buf_rd_sel]) begin
            rd_buf_rd_sel <= rd_buf_rd_next;
        end
        else if (rd_valid) begin
            rd_buf_rd_next <= (rd_buf_rd_sel == N) ? 1 : (rd_buf_rd_sel + 1);              
        end
    end    
end




/////////////////////////////////////////////////////////////
//
// IO Buffers
//
/////////////////////////////////////////////////////////////

    
generate
for (i=0; i<32; i=i+1) begin
    IOBUF data_iobuf_inst (
        .IO(ft601_data[i]),
        .I(wr_buf_rd_data[wr_buf_rd_sel][i]),
        .O(rd_buf_wr_data[i]),
        .T(data_oe_n)
    );    
end
endgenerate

generate
for (i=0; i<4; i=i+1) begin
    IOBUF be_iobuf_inst (
        .IO(ft601_be[i]),
        .I(wr_buf_rd_data[wr_buf_rd_sel][i+32]),
        .O(rd_buf_wr_data[i+32]),
        .T(data_oe_n)
    );    
end
endgenerate
    
 
/////////////////////////////////////////////////////////////
//
// Control logic
// 245 Sync FIFO Mode
//
/////////////////////////////////////////////////////////////   
    
    
always @(negedge clk0_mmcm) begin
	if (reset || !locked_mmcm) begin
        do_read_next <= 0;
		state <= STATE_IDLE;
	end
	else begin
		case (state) 
		STATE_IDLE: begin
            do_read_next <= !do_read_next;
            if (start_read) begin
                state <= STATE_BTA;
            end
            else if (start_write) begin
                state <= STATE_WRITE;
            end            
		end
		STATE_BTA: begin
            state <= STATE_READ;
		end
		STATE_READ: begin
            if (done_read) begin
                state <= STATE_IDLE;
            end
		end
		STATE_WRITE: begin
            if (done_write) begin
                state <= STATE_IDLE;
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
	end
	STATE_BTA: begin
		ft601_oe_n <= 1'b0;
		ft601_rd_n <= 1'b1;
	end
	STATE_READ: begin
		ft601_oe_n <= 1'b0;
		ft601_rd_n <= 1'b0;
	end
	STATE_WRITE: begin
		ft601_oe_n <= 1'b1;
		ft601_rd_n <= 1'b1;
	end
    endcase
end


assign data_oe_n = (state == STATE_BTA || state == STATE_READ);


endmodule
