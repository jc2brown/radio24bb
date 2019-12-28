
// Controller for the PCAL6416A I2C I/O expander
// Talks to i2c_basic
// Automatically updates up to 16 output pins on a PCAL6416A

// Interrupt is cleared when data is read from the port that originated it 

module pcal6416a_ctrl
#(
)
(
    input clk,
    input reset,
    
    input enable,
            
    input [15:0] in,    
    output reg [15:0] out,
    output reg out_valid,
    
    input irq,
    
    input [15:0] inputs,
    input start_init,    
    input start,
    output reg done,
    
    output reg i2c_start,
    input i2c_done,
    
    input [6:0] addr,
    
    output reg [1:0] num_wr_bytes,
    output reg [7:0] wr_data0,
    output reg [7:0] wr_data1,
    output reg [7:0] wr_data2,
        
    output reg [1:0] num_rd_bytes,
    input [7:0] rd_data0,
    input [7:0] rd_data1
    
);
    
reg [3:0] state;


localparam STATE_INIT1 = 0;
localparam STATE_INIT2 = 1;
localparam STATE_IDLE = 2;
localparam STATE_UPDATE = 3;
localparam STATE_WRITE0 = 4;
localparam STATE_WRITE1 = 5;
localparam STATE_READ0 = 6;
localparam STATE_READ1 = 7;
localparam STATE_READ2 = 8;
localparam STATE_READ3 = 9;
localparam STATE_UNINITED = 10;



reg [15:0] in_d1 = 16'h0;

reg do_read;
reg do_write;


always @(posedge clk) begin
    if (reset) begin
        state <= STATE_UNINITED;
        in_d1 <= !in;
        i2c_start <= 0;
        wr_data0 <= 0;
        wr_data2 <= 0;
        wr_data1 <= 0;
        do_read <= 0;
        do_write <= 0;
        done <= 0;
        out <= 0;
        out_valid <= 0;
    end
    else begin
    
        out_valid <= 0;      
    
        if (enable) begin
        
        
            case (state)
            
            STATE_UNINITED: begin
                if (start_init) begin
                    done <= 0;
                    state <= STATE_INIT1;
                end
            end
            
            STATE_INIT1: begin
                num_wr_bytes <= 3;
                wr_data0 <= 8'h06; // Config port
                wr_data1 <= inputs[7:0];
                wr_data2 <= inputs[15:0];  
                i2c_start <= 1'b1;          
                state <= STATE_INIT2;
            end           
            STATE_INIT2: begin
                i2c_start <= 1'b0;
                if (i2c_done) begin
                    do_read <= 1;
                    do_write <= 1;
                    state <= STATE_UPDATE;
                end
            end
            
            
            STATE_IDLE: begin
                done <= 1;
                if (start) begin                
                    do_write <= (in != in_d1);
                    do_read <= irq;
                    done <= 0;
                    state <= STATE_UPDATE;
                end
            end
            
            STATE_UPDATE: begin
                
                if (do_read) begin                
                    state <= STATE_READ0;
                end
                else if (do_write) begin
                    state <= STATE_WRITE0;
                end
                else begin
                    state <= STATE_IDLE;
                end                            
            end
                                              
                        
            STATE_WRITE0: begin  
                num_wr_bytes <= 3;
                wr_data0 <= 8'h02; // Output port
                wr_data1 <= in[7:0];
                wr_data2 <= in[15:8];  
                in_d1 <= in;                    
                i2c_start <= 1'b1;     
                state <= STATE_WRITE1;
            end
            STATE_WRITE1: begin  
                i2c_start <= 1'b0;
                if (i2c_done) begin
                    do_write <= 0;
                    state <= STATE_UPDATE;
                end
            end
                     
                        
            STATE_READ0: begin  
                num_wr_bytes <= 1;
                wr_data0 <= 8'h00; // Input port
                i2c_start <= 1'b1;     
                state <= STATE_READ1;
            end
            STATE_READ1: begin  
                i2c_start <= 1'b0;
                if (i2c_done) begin
                    state <= STATE_READ2;
                end
            end                                        
            STATE_READ2: begin  
                num_rd_bytes <= 2;
                wr_data0 <= 8'h00; // Input port
                i2c_start <= 1'b1;     
                state <= STATE_READ3;
            end
            STATE_READ3: begin  
                i2c_start <= 1'b0;
                if (i2c_done) begin
                    do_read <= 0;
                    out <= {rd_data1, rd_data0};         
                    out_valid <= 1;      
                    state <= STATE_UPDATE;
                end
            end
                        
            endcase
            
        end
            
    end
end
    
    
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
