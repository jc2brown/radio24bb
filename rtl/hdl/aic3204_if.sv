`timescale 1ps / 1ps


module aic3204_if(
    
    /////////////////////////////////////////////
    // Device interface
    /////////////////////////////////////////////

    output wire aic3204_mclk,
    input wire aic3204_wclk,
    input wire aic3204_bclk,
    output wire aic3204_din,
    input wire aic3204_dout,
    

    /////////////////////////////////////////////
    // PL interface
    /////////////////////////////////////////////

    input wire clk,
    input wire mclk,
    input wire reset,
    
    output wire [31:0] nw_fifo_rd_data,
    output wire nw_fifo_rd_valid,
    input wire nw_fifo_rd_en,
    output wire nw_fifo_empty,
    
    output wire [31:0] pw_fifo_rd_data,
    output wire pw_fifo_rd_valid,
    input wire pw_fifo_rd_en,
    output wire pw_fifo_empty,
        
    output wire [31:0] nw_fifo_wr_data,
    input wire nw_fifo_wr_en,
    output wire nw_fifo_full,
    
    output wire [31:0] pw_fifo_wr_data,
    input wire pw_fifo_wr_en,
    output wire pw_fifo_full


);


reg bclk;
always @(posedge clk) bclk <= aic3204_bclk;

reg bclk_d1;
always @(posedge clk) bclk_d1 <= bclk;

reg bclk_posedge;
always @(posedge clk) bclk_posedge <= bclk && !bclk_d1;

reg bclk_negedge;
always @(posedge clk) bclk_negedge <= !bclk && bclk_d1;


reg wclk;
always @(posedge clk) wclk <= aic3204_wclk;

reg wclk_d1;
always @(posedge clk) wclk_d1 <= wclk;

reg wclk_posedge;
always @(posedge clk) wclk_posedge <= wclk && !wclk_d1;

reg wclk_negedge;
always @(posedge clk) wclk_negedge <= !wclk && wclk_d1;



/////////////////////////////////////////////////////////////
//
// Output Registers
//
/////////////////////////////////////////////////////////////


ODDR clk_oddr (
    .Q(aic3204_mclk),
    .D1(1'b1),
    .D2(1'b0),
    .C(mclk),
    .CE(1'b1),
    .S(1'b0),
    .R(reset)
);    



/////////////////////////////////////////////////////////////
//
// Output FIFO
//
/////////////////////////////////////////////////////////////

wire [31:0] nw_out_fifo;
wire [31:0] pw_out_fifo;


xpm_fifo_async #(
    .CDC_SYNC_STAGES(2),       // DECIMAL
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(32),      // DECIMAL
    .WRITE_DATA_WIDTH(32)     // DECIMAL
)
out_nw_fifo_inst (

    .rst(reset),   
    
    .wr_clk(clk),
    .din(nw_fifo_wr_data),      
    .wr_en(nw_fifo_wr_en),
    .full(nw_fifo_full),    
    
    .rd_clk(clk),
    .dout(nw_out_fifo),  
    .rd_en(wclk_negedge)
);


xpm_fifo_async #(
    .CDC_SYNC_STAGES(2),       // DECIMAL
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(32),      // DECIMAL
    .WRITE_DATA_WIDTH(32)     // DECIMAL
)
out_pw_fifo_inst (

    .rst(reset),   
    
    .wr_clk(clk),
    .din(pw_fifo_wr_data),      
    .wr_en(pw_fifo_wr_en),
    .full(pw_fifo_full),    
    
    .rd_clk(clk),
    .dout(pw_out_fifo),  
    .rd_en(wclk_posedge)
);


/////////////////////////////////////////////////////////////
//
// Input Registers
//
/////////////////////////////////////////////////////////////

reg [31:0] pw = 'h0; // positive-wclk shift register 
reg [31:0] nw = 'h0; // negative-wclk shift register 

always @(posedge clk) begin
    if (bclk_posedge) begin
        if (!wclk) begin
            pw <= 32'h00;
        end
        else begin 
            pw <= {aic3204_dout, pw[31:1]};
        end
    end
end

always @(posedge clk) begin
    if (bclk_posedge) begin
        if (wclk) begin
            nw <= 32'h00;
        end
        else begin 
            nw <= {aic3204_dout, nw[31:1]};
        end
    end
end

/////////////////////////////////////////////////////////////
//
// Input FIFO
//
/////////////////////////////////////////////////////////////
  
    

xpm_fifo_async #(
    .USE_ADV_FEATURES("1707"),
    .CDC_SYNC_STAGES(2),       // DECIMAL
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(32),      // DECIMAL
    .WRITE_DATA_WIDTH(32)     // DECIMAL
)
in_nw_fifo_inst (

    .rst(reset),   
    
    .wr_clk(clk),
    .din({16'h0, nw[31:16]}),      
    .wr_en(wclk_posedge),    
    
    .rd_clk(clk),
    .dout(nw_fifo_rd_data),  
    .data_valid(nw_fifo_rd_valid),
    .rd_en(nw_fifo_rd_en),    
    .empty(nw_fifo_empty)  
);



xpm_fifo_async #(
    .USE_ADV_FEATURES("1707"),
    .CDC_SYNC_STAGES(2),       // DECIMAL
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(4096),   // DECIMAL
    .READ_DATA_WIDTH(32),      // DECIMAL
    .WRITE_DATA_WIDTH(32)     // DECIMAL
)
in_pw_fifo_inst (

    .rst(reset),   
    
    .wr_clk(clk),
    .din(pw >>> 16),      
    .wr_en(wclk_negedge),    
    
    .rd_clk(clk),
    .dout(pw_fifo_rd_data),  
    .data_valid(pw_fifo_rd_valid),
    .rd_en(pw_fifo_rd_en),    
    .empty(pw_fifo_empty)  
);



/*


// 4KB
FIFO36E1 
#(
    .DATA_WIDTH(36),                    // Sets data width to 4-72
    .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
    .EN_SYN("FALSE"),                  // Specifies FIFO as Asynchronous (FALSE) or Synchronous (TRUE)
    .FIRST_WORD_FALL_THROUGH("FALSE"), // Sets the FIFO FWFT to FALSE, TRUE
    .SIM_DEVICE("7SERIES")           // Must be set to "7SERIES" for simulation behavior
)
FIFO36E1_in_pw_fifo_inst
(
    .RST(1'b0),     
    .RSTREG(1'b0),      

    .DI(pw),                       
    .DIP(4'b0),      
    .WREN(1'b1),
    .WRCLK(!aic3204_wclk),
        
    .DO(pw_fifo_rd_data),
    .RDCLK(clk),
    .RDEN(pw_fifo_rd_en),
    .REGCE(1'b1),    
    .EMPTY(pw_fifo_empty)
   
);

*/

reg [15:0] sr;

always @(posedge clk) begin
    if (wclk_negedge) begin
        sr <= pw;
    end
end






endmodule
