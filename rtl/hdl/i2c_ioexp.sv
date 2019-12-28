`timescale 1ps / 1ps


// Simple output-only controller for the PCAL6416A I2C I/O expander
// Automatically updates up to 16 output pins on a PCAL6416A


module i2c_ioexp
#(
    parameter CLK_DIV_BITS = 10, // sclk = clk / 2^(CLK_DIV_BITS+1)
    parameter USE_IN0 = 1,
    parameter USE_IN1 = 0,
    parameter INPUTS0 = 16'h00,
    parameter INPUTS1 = 16'h00,
    parameter USE_IOBUF = 0
    
    //parameter ADDR_PIN = 0
)
(
    input clk,
    input reset,
            
    input [15:0] in,
    output reg [15:0] out0,
    input irq0,
        
    input [15:0] in1,
    output reg [15:0] out1,
    input irq1,
    
    output wire sclk,
    output wire sdata,
    input sdata_in,
    output wire sdata_oe_n,
    
    inout sda
    
);
    
    
reg [15:0] in_d1 [0:1];
wire irq [0:1];
assign irq[0] = irq0;
assign irq[1] = irq1; // = { irq0, irq1 };
wire [15:0] inputs [0:1];
assign inputs[0] = INPUTS0;
assign inputs[1] = INPUTS1;
wire [6:0] addr [0:1] = { 7'h20, 7'h21 };    
    
wire i2c_start;
wire i2c_done;

reg read;
reg write;

reg [1:0] sel = 0;
    
wire [1:0] num_wr_bytes;
wire [7:0] wr_data0;
wire [7:0] wr_data1;
wire [7:0] wr_data2;

wire [1:0] num_rd_bytes;
wire [7:0] rd_data0;
wire [7:0] rd_data1;

    
i2c_basic
#(
    .CLK_DIV_BITS(CLK_DIV_BITS),
    .USE_IOBUF(USE_IOBUF)
)
i2c_basic_inst
(
    .clk(clk),
    .reset(reset),
        
    .addr(addr[sel]),
     
    .num_wr_bytes(num_wr_bytes),        
    .wr_data0(wr_data0),
    .wr_data1(wr_data1),
    .wr_data2(wr_data2),
         
    .num_rd_bytes(num_rd_bytes),        
    .rd_data0(rd_data0),
    .rd_data1(rd_data1),
    
    .start(i2c_start),    
    .done(i2c_done),
    
    .sclk(sclk),
    .sdata_out(sdata),
    .sdata_in(sdata_in),
    .sdata_oe_n(sdata_oe_n),
    
    .sda(sda)     
 );



wire [15:0] out;
wire out_valid;

reg enable = 1;
//reg start_init;
//reg start;
wire done;



reg [3:0] state;


localparam STATE_INIT0A = 0;
localparam STATE_INIT0B = 1;
localparam STATE_INIT1A = 2;
localparam STATE_INIT1B = 3;
localparam STATE_IDLE = 4;
localparam STATE_LOOP0 = 5;
localparam STATE_LOOP1 = 6;
localparam STATE_LOOP2 = 7;
localparam STATE_LOOP3 = 8;
localparam STATE_LOOP4 = 9;
localparam STATE_LOOP5 = 10;
localparam STATE_RESET = 11;




wire start_init = (state == STATE_INIT0A) || (state == STATE_INIT1A);
wire start = (state == STATE_LOOP1) || (state == STATE_LOOP4);




pcal6416a_ctrl pcal6416a_ctrl_inst (

    .clk(clk),
    .reset(reset),
    
    .enable(enable),
    
    .in((sel == 0) ? in : in1),
    .out(out),
    .out_valid(out_valid),
    
    .write(write),
    .read(irq[sel]),
    
    .inputs(inputs[sel]),
    
    .start_init(start_init),
    .start(start),
    .done(done),
    
    .i2c_start(i2c_start),
    .i2c_done(i2c_done),
    
    .addr(addr[sel]),
    
    .num_wr_bytes(num_wr_bytes),
    .wr_data0(wr_data0),
    .wr_data1(wr_data1),
    .wr_data2(wr_data2),
    
    .num_rd_bytes(num_rd_bytes),
    .rd_data0(rd_data0),   
    .rd_data1(rd_data1)
    
);

    
    
    
    
    
    



always @(posedge clk) begin
    if (reset) begin
        state <= STATE_RESET;
        in_d1[0] <= ~in;
        in_d1[1] <= ~in1;
        
        read <= 0;
        write <= 0;
        
        sel <= 0;
        //start_init <= 0;  
//        start <= 0;
        
    end
    else begin
        case (state)
        
        STATE_RESET: begin
            if (done) begin
                state <= STATE_INIT0A;
            end
        end
        
        STATE_INIT0A: begin
            if (USE_IN0) begin
                sel <= 0;
//                start_init <= 1;      
                state <= STATE_INIT0B;
            end
            else begin
                state <= STATE_INIT1A;
            end
        end           
        STATE_INIT0B: begin
//            start_init <= 1'b0;
            if (done) begin
                state <= STATE_INIT1A;
            end
        end
                    
        STATE_INIT1A: begin
            if (USE_IN1) begin
                sel <= 1;
//                start_init <= 1;      
                state <= STATE_INIT1B;
            end
            else begin
                state <= STATE_IDLE;
            end
        end           
        STATE_INIT1B: begin
//            start_init <= 1'b0;
            if (done) begin
                state <= STATE_IDLE;
            end
        end
        
        
        STATE_IDLE: begin
            state <= STATE_LOOP0;
        end
        
        
        STATE_LOOP0: begin      
            write <= 0;          
            if (in != in_d1[0]) begin    
                write <= 1;              
                in_d1[0] <= in;
                sel <= 0;     
                state <= STATE_LOOP1;
            end
            else begin
                state <= STATE_LOOP3;
            end
        end
        STATE_LOOP1: begin   
            state <= STATE_LOOP2;        
        end
        STATE_LOOP2: begin
            if (done) begin
                if (out_valid) begin
                    out0 <= out;
                end
                state <= STATE_LOOP3;
            end      
        end
        
        
        
        STATE_LOOP3: begin      
            write <= 0;          
            if (in1 != in_d1[1]) begin     
                write <= 1;         
                in_d1[1] <= in1;
                sel <= 1;         
                state <= STATE_LOOP4;
            end
            else begin
                state <= STATE_IDLE;
            end
        end
        STATE_LOOP4: begin   
            state <= STATE_LOOP5;        
        end
        STATE_LOOP5: begin
            if (done) begin
                if (out_valid) begin
                    out1 <= out;
                end
                state <= STATE_IDLE;
            end      
        end
        
        
        endcase
    end
end
    
    
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
