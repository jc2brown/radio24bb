`timescale 1ps / 1ps


// Simple output-only controller for the PCAL6416A I2C I/O expander
// Automatically updates up to 16 output pins on a PCAL6416A


module i2c_ioexp
#(
    parameter CLK_DIV_BITS = 10, // sclk = clk / 2^(CLK_DIV_BITS+1)
    parameter USE_IN1 = 1,
    parameter USE_IN2 = 0
    //parameter ADDR_PIN = 0
)
(
    input clk,
    input reset,
            
    input [15:0] in,
    input [15:0] in2,
    
    output wire sclk,
    output wire sdata,
    output wire sdata_oe_n
    
);
    
    

reg [2:0] state;
reg [2:0] post_update_state;


localparam STATE_INIT1A = 0;
localparam STATE_INIT1B = 1;
localparam STATE_INIT2A = 2;
localparam STATE_INIT2B = 3;
localparam STATE_IDLE = 4;
localparam STATE_UPDATE0 = 5;
localparam STATE_UPDATE1 = 6;

reg start;
wire done;
reg [7:0] wr_data0;
reg [7:0] wr_data1;
reg [7:0] wr_data2;



reg [15:0] in_d1 = 16'h0;
reg [15:0] in2_d1 = 16'h0;


reg [6:0] addr;



always @(posedge clk) begin
    if (reset) begin
        state <= STATE_INIT1A;
    end
    else begin
        case (state)
        
        STATE_INIT1A: begin
            if (USE_IN1) begin
                addr <= 7'h20;
                wr_data0 <= 8'h06;
                wr_data1 <= 8'h00;
                wr_data2 <= 8'h00;  
                start <= 1'b1;          
                state <= STATE_INIT1B;
            end
            else begin
                state <= STATE_INIT2A;
            end
        end           
        STATE_INIT1B: begin
            start <= 1'b0;
            if (done) begin
                post_update_state <= STATE_INIT2A;
                state <= STATE_UPDATE0;
            end
        end
                    
        STATE_INIT2A: begin
            if (USE_IN2) begin
                addr <= 7'h21;
                wr_data0 <= 8'h06;
                wr_data1 <= 8'h00;
                wr_data2 <= 8'h00;  
                start <= 1'b1;          
                state <= STATE_UPDATE0;
            end
            else begin
                state <= STATE_IDLE;
            end
        end           
        STATE_INIT2B: begin
            start <= 1'b0;
            if (done) begin
                post_update_state <= STATE_IDLE;
                state <= STATE_UPDATE0;
            end
        end
        
        
        STATE_IDLE: begin
            post_update_state <= STATE_IDLE;
            if (in != in_d1) begin 
                in_d1 <= in;   
                addr <= 7'h20;
                wr_data1 <= in[7:0];
                wr_data2 <= in[15:8];  
                state <= STATE_UPDATE0;
            end
            else if (in2 != in2_d1) begin 
                in2_d1 <= in2;   
                addr <= 7'h21;
                wr_data1 <= in2[7:0];
                wr_data2 <= in2[15:8];  
                state <= STATE_UPDATE0;
            end
        end
        
        
        STATE_UPDATE0: begin  
            wr_data0 <= 8'h02;
            start <= 1'b1;     
            state <= STATE_UPDATE1;
        end
        STATE_UPDATE1: begin  
            start <= 1'b0;
            if (done) begin
                state <= post_update_state;
            end
        end
        endcase
    end
end
    
    
   
    
    
    
    
    
i2c_basic
#(
    .CLK_DIV_BITS(CLK_DIV_BITS)
)
i2c_basic_inst
(
    .clk(clk),
    .reset(reset),
        
    .addr(addr),
     
    .num_wr_bytes(2'd3),        
    .wr_data0(wr_data0),
    .wr_data1(wr_data1),
    .wr_data2(wr_data2),
    
    .start(start),    
    .done(done),
    
    .sclk(sclk),
    .sdata_out(sdata),
    .sdata_oe_n(sdata_oe_n)     
 );

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
