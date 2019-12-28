`timescale 1ps / 1ps


// Basic I2C controller
// Supports 7-bit addresses, 1-, 2-, or 3-byte write payloads, and 1- or 2-byte read payloads 

module i2c_basic
#(
    parameter CLK_DIV_BITS = 8,
    parameter USE_IOBUF = 0
)
(
    input clk,
    input reset,
        
    input [6:0] addr,
     
    input [1:0] num_wr_bytes,        
    input [7:0] wr_data0,
    input [7:0] wr_data1,
    input [7:0] wr_data2,
    
    input [1:0] num_rd_bytes,
    output reg [7:0] rd_data0,
    output reg [7:0] rd_data1,
    
    input start,    
    output reg done,
    
    output reg sclk,
    output reg sdata_out,
    input wire sdata_in,
    output reg sdata_oe_n,
    
    inout sda
    
);
    
    
reg [1:0] num_rd_bytes_reg;
reg [1:0] num_wr_bytes_reg;

reg [1:0] state;

localparam STATE_IDLE = 0;
localparam STATE_LOAD = 1;
localparam STATE_SHIFT = 2;



reg [CLK_DIV_BITS:0] divclk;
reg [CLK_DIV_BITS:0] divclk_d1;

always @(posedge clk) begin
    if (reset || state == STATE_IDLE) begin
        divclk_d1 <= {CLK_DIV_BITS{1'b0}};
        divclk <= {CLK_DIV_BITS{1'b0}};
    end
    else begin
        divclk_d1 <= divclk;
        divclk <= divclk + 1;
    end
end
    
    

    
reg sclk_ce;
always @(posedge clk) begin
    if (reset) begin
        sclk_ce <= 1'b0;
    end
    else begin
       sclk_ce <= divclk[CLK_DIV_BITS-1] && !divclk_d1[CLK_DIV_BITS-1];
    end
end


reg sdata_ce;
always @(posedge clk) begin
    if (reset) begin
        sdata_ce <= 1'b0;
    end
    else begin
        sdata_ce <= divclk[CLK_DIV_BITS] && !divclk_d1[CLK_DIV_BITS];
    end
end
    

wire _sdata_in;


reg start_ce;
always @(posedge clk) begin
    if (reset) begin
        start_ce <= 1'b0;
    end
    else begin
        start_ce <= divclk[CLK_DIV_BITS-2] && !divclk_d1[CLK_DIV_BITS-2];
    end
end

localparam CSR_BITS = 75;
localparam DSR_BITS = 39;

reg [CSR_BITS-1:0] csr;
reg [DSR_BITS-1:0] dsr;
reg [DSR_BITS-1:0] osr;
reg [DSR_BITS-1:0] isr;


    
always @(posedge clk) begin
    if (reset) begin
        state <= STATE_IDLE;
        csr <= {CSR_BITS{1'b1}};
        dsr <= {DSR_BITS{1'b1}};
        osr <= {DSR_BITS{1'b0}};
        isr <= {DSR_BITS{1'b0}};
        done <= 1'b0;
        rd_data0 <= 'h0;
        rd_data1 <= 'h0;
    end
    else begin
        case (state)
        STATE_IDLE: begin
            done <= 1'b1;
            if (start) begin
                done <= 0;
                num_wr_bytes_reg <= num_wr_bytes;
                num_rd_bytes_reg <= num_rd_bytes;
                state <= STATE_LOAD;
            end
        end        
        
        STATE_LOAD: begin        
            if (sclk_ce) begin
                if (num_wr_bytes_reg == 1) begin
                    csr <= {1'b1,1'b0,      {9{2'b01}},       {9{2'b01}},                                               1'b0,{36{1'b1}}};
                    dsr <= {1'b1,1'b0,      addr,1'b0,1'b1,   wr_data0,1'b1,                                            1'b0,{18{1'b1}}};
                    osr <= {1'b0,1'b0,      7'b0,1'b0,1'b1,   8'b0,1'b1,                                                1'b0,{18{1'b0}}};
                    $display("> 1");
                end
                else if (num_wr_bytes_reg == 2) begin
                    csr <= {1'b1,1'b0,      {9{2'b01}},       {9{2'b01}},       {9{2'b01}},1'b0,                        {18{1'b1}}};
                    dsr <= {1'b1,1'b0,      addr,1'b0,1'b1,   wr_data0,1'b1,    wr_data1,1'b1,                          1'b0,{9{1'b1}}};
                    osr <= {1'b0,1'b0,      7'b0,1'b0,1'b1,   8'b0,1'b1,        8'b0,1'b1,                              1'b0,{9{1'b0}}};
                    $display("> 2");
                end
                else if (num_wr_bytes_reg == 3) begin
                    csr <= {1'b1,1'b0,      {9{2'b01}},       {9{2'b01}},       {9{2'b01}},         {9{2'b01}},         1'b0};
                    dsr <= {1'b1,1'b0,      addr,1'b0,1'b1,   wr_data0,1'b1,    wr_data1,1'b1,      wr_data2,1'b1,      1'b0};
                    osr <= {1'b0,1'b0,      7'b0,1'b0,1'b1,   8'b0,1'b1,        8'b0,1'b1,          8'b0,1'b1,          1'b0};
                    $display("> 3");
                end
                else if (num_rd_bytes_reg == 1) begin
                    csr <= {1'b1,1'b0,      {9{2'b01}},       {9{2'b01}},                                               1'b0,{36{1'b1}}};
                    dsr <= {1'b1,1'b0,      addr,1'b1,1'b1,   8'b0,1'b0,                                                1'b0,{18{1'b1}}};
                    osr <= {1'b0,1'b0,      7'b0,1'b0,1'b1,   {8{1'b1}},1'b1,                                                1'b0,{18{1'b0}}};    
                    $display("> 4");            
                end
                else if (num_rd_bytes_reg == 2) begin                    
                    csr <= {1'b1,1'b0,      {9{2'b01}},       {9{2'b01}},       {9{2'b01}},                             1'b0,{18{1'b1}}};
                    dsr <= {1'b1,1'b0,      addr,1'b1,1'b1,   8'b0,1'b0,        8'b0,1'b0,                              1'b0,{9{1'b1}}};
                    osr <= {1'b0,1'b0,      7'b0,1'b0,1'b1,   {8{1'b1}},1'b0,   {8{1'b1}},1'b1,                         1'b0,{9{1'b0}}};            
                    $display("> 5");            
                end
                
                state <= STATE_SHIFT;
            end
        end
        
        STATE_SHIFT: begin        
            if (sclk_ce) begin
                csr <= {csr[CSR_BITS-2:0], 1'b1};
            end
            if (sdata_ce) begin
                dsr <= {dsr[DSR_BITS-2:0], 1'b1};
                osr <= {osr[DSR_BITS-2:0], 1'b0};
                isr <= {isr[DSR_BITS-2:0], _sdata_in};
            end
            if (&csr && &dsr) begin
                if (num_rd_bytes_reg == 1) begin
                    rd_data0 <= isr[9:2];
                end
                else if (num_rd_bytes_reg == 2) begin
                    rd_data0 <= isr[18:11];
                    rd_data1 <= isr[9:2];
                end
                done <= 1'b1;
                state <= STATE_IDLE;
            end
        end
        endcase
    end
end
    
    
   
always @(posedge clk) begin
    sclk <= csr[CSR_BITS-1];
    sdata_out <= dsr[DSR_BITS-1];
    sdata_oe_n <= osr[DSR_BITS-1];
 end
     
    
    
generate 
if (USE_IOBUF) begin

IOBUF sda_iobuf (
    .I(sdata_out),
    .O(_sdata_in),
    .IO(sda),
    .T(sdata_oe_n)
);

end  
else begin

assign _sdata_in = sdata_in;

end
endgenerate
    
    
    
    
    
    
    
endmodule





