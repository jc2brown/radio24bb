

module mpx_regs (
    
    input clk,
    input reset,
    

	output reg [31:0] pilot_gain,
	output reg [7:0] rom_data,
	output reg rom_data_wr_en,
	output reg [31:0] step,
	output reg [1:0] stat_cfg,
	output reg [31:0] stat_limit,
	input wire [7:0] stat_min,
	input wire [7:0] stat_max,
	input wire [31:0] stat_count,
	output reg [24:0] filter_cfg,
	output reg filter_cfg_wr_en,
	output reg [3:0] mux,
	output reg enable_preemph,
	output reg [29:0] preemph_b0,
	output reg [29:0] preemph_b1,
	output reg [29:0] preemph_b2,
	output reg [29:0] preemph_a1,
	output reg [29:0] preemph_a2,


        
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
        pilot_gain <= 32'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h00) begin
            pilot_gain <= pwdata[31:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        rom_data <= 8'd0; 
		rom_data_wr_en <= 1'b0;       
    end
    else begin 
		rom_data_wr_en <= 1'b0;                     
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h04) begin
            rom_data <= pwdata[7:0]; 
			rom_data_wr_en <= 1'b1;      
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        step <= 32'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h08) begin
            step <= pwdata[31:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        stat_cfg <= 2'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h0C) begin
            stat_cfg <= pwdata[1:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        stat_limit <= 32'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h10) begin
            stat_limit <= pwdata[31:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        stat_min <= 8'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h14) begin
            stat_min <= pwdata[7:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        stat_max <= 8'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h18) begin
            stat_max <= pwdata[7:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        stat_count <= 32'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h1C) begin
            stat_count <= pwdata[31:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        filter_cfg <= 25'd0; 
		filter_cfg_wr_en <= 1'b0;       
    end
    else begin 
		filter_cfg_wr_en <= 1'b0;                     
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h20) begin
            filter_cfg <= pwdata[24:0]; 
			filter_cfg_wr_en <= 1'b1;      
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        mux <= 4'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h24) begin
            mux <= pwdata[3:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        enable_preemph <= 1'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h28) begin
            enable_preemph <= pwdata[0:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        preemph_b0 <= 30'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h2C) begin
            preemph_b0 <= pwdata[29:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        preemph_b1 <= 30'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h30) begin
            preemph_b1 <= pwdata[29:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        preemph_b2 <= 30'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h34) begin
            preemph_b2 <= pwdata[29:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        preemph_a1 <= 30'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h38) begin
            preemph_a1 <= pwdata[29:0];       
        end
    end
end

always @(posedge clk)
begin
    if (reset) begin                          
        preemph_a2 <= 30'd0;        
    end
    else begin                      
        if (penable && psel && pwrite && {paddr[5:2], 2'b00} == 6'h3C) begin
            preemph_a2 <= pwdata[29:0];       
        end
    end
end
              

        

always @(*)
begin
    case ({paddr[5:2], 2'b00})        
		6'h00: prdata = {{0{1'b0}}, pilot_gain}, pilot_gain};
		6'h08: prdata = {{0{1'b0}}, step}, step};
		6'h0C: prdata = {{30{1'b0}}, stat_cfg}, stat_cfg};
		6'h10: prdata = {{0{1'b0}}, stat_limit}, stat_limit};
		6'h14: prdata = {{24{1'b0}}, stat_min}, stat_min};
		6'h18: prdata = {{24{1'b0}}, stat_max}, stat_max};
		6'h1C: prdata = {{0{1'b0}}, stat_count}, stat_count};
		6'h24: prdata = {{28{1'b0}}, mux}, mux};
		6'h28: prdata = {{31{1'b0}}, enable_preemph}, enable_preemph};
		6'h2C: prdata = {{2{1'b0}}, preemph_b0}, preemph_b0};
		6'h30: prdata = {{2{1'b0}}, preemph_b1}, preemph_b1};
		6'h34: prdata = {{2{1'b0}}, preemph_b2}, preemph_b2};
		6'h38: prdata = {{2{1'b0}}, preemph_a1}, preemph_a1};
		6'h3C: prdata = {{2{1'b0}}, preemph_a2}, preemph_a2};                         
        default: prdata = 32'h0;  
    endcase
end    




endmodule

