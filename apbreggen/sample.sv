

module mpx_regs (
    
    input clk,
    input reset,
    

	output reg one_bit_rw_register,
	output reg signed [9:0] ten_bit_rw_register,
	input wire one_bit_r_register,
	input wire [9:0] ten_bit_r_register,
	output reg [10:0] eleven_bit_rwe_register,
	output reg eleven_bit_rwe_register_wr_en,
	output reg one_bit_w_register,
	output reg [10:0] big_we_register,
	output reg big_we_register_wr_en,
	output reg [10:0] big_we_register2,
	output reg big_we_register2_wr_en,


        
    input penable,
    input psel,
    input [31:0] paddr,
    input pwrite,
    input [31:0] pwdata,
    output reg [31:0] prdata  
        
);





always @(posedge clk)
begin
    if (reset) begin                          
        one_bit_rw_register <= 1'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[4:2], 2'b00} == 5'h00) begin
            one_bit_rw_register <= pwdata[0:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        ten_bit_rw_register <= 10'sd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[4:2], 2'b00} == 5'h04) begin
            ten_bit_rw_register <= pwdata[9:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        one_bit_r_register <= 1'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[4:2], 2'b00} == 5'h08) begin
            one_bit_r_register <= pwdata[0:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        ten_bit_r_register <= 10'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[4:2], 2'b00} == 5'h0C) begin
            ten_bit_r_register <= pwdata[9:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        eleven_bit_rwe_register <= 11'd0; 
		eleven_bit_rwe_register_wr_en <= 1'b0;       
    end
    else begin 
		eleven_bit_rwe_register_wr_en <= 1'b0;                     
        if (penable && psel && pwrite && {paddr[4:2], 2'b00} == 5'h10) begin
            eleven_bit_rwe_register <= pwdata[10:0]; 
			eleven_bit_rwe_register_wr_en <= 1'b1;      
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        one_bit_w_register <= 1'd1;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[4:2], 2'b00} == 5'h14) begin
            one_bit_w_register <= pwdata[0:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        big_we_register <= 11'd0; 
		big_we_register_wr_en <= 1'b0;       
    end
    else begin 
		big_we_register_wr_en <= 1'b0;                     
        if (penable && psel && pwrite && {paddr[4:2], 2'b00} == 5'h18) begin
            big_we_register <= pwdata[10:0]; 
			big_we_register_wr_en <= 1'b1;      
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        big_we_register2 <= 11'd0; 
		big_we_register2_wr_en <= 1'b0;       
    end
    else begin 
		big_we_register2_wr_en <= 1'b0;                     
        if (penable && psel && pwrite && {paddr[4:2], 2'b00} == 5'h1C) begin
            big_we_register2 <= pwdata[10:0]; 
			big_we_register2_wr_en <= 1'b1;      
        end
    end
end
              

        

always @(*)
begin
    case ({paddr[4:2], 2'b00})        
		5'h00: prdata = {{31{1'b0}}, one_bit_rw_register}, one_bit_rw_register};
		5'h04: prdata = {{22{ten_bit_rw_register[9]}}, ten_bit_rw_register}, ten_bit_rw_register};
		5'h08: prdata = {{31{1'b0}}, one_bit_r_register}, one_bit_r_register};
		5'h0C: prdata = {{22{1'b0}}, ten_bit_r_register}, ten_bit_r_register};
		5'h10: prdata = {{21{1'b0}}, eleven_bit_rwe_register}, eleven_bit_rwe_register};
		5'h18: prdata = {{21{1'b0}}, big_we_register}, big_we_register};
		5'h1C: prdata = {{21{1'b0}}, big_we_register2}, big_we_register2};                         
        default: prdata = 32'h0;  
    endcase
end    




endmodule

