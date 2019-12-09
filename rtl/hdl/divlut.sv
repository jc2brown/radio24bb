`timescale 1ps / 1ps


module divlut (

	input clk,
    input reset,
    
    input run,

    input [10:0] wr_data,
    input wr_en,
        
    input [10:0] rd_addr,
    input rd_en,
    
    // 1 cycle latency
    output reg [10:0] rd_data,
    output reg rd_data_valid
    
);
    

reg [10:0] wr_addr = 0;    
    
reg [10:0] div_table [0:2047];

always @(posedge clk) begin
    if (reset) begin
        rd_data <= 0;
    end
    else begin
        if (!run) begin
            if (wr_en) begin
                div_table[wr_addr] <= wr_data;
                wr_addr <= wr_addr + 1;
            end
        end
        else begin
            wr_addr <= 0; // reset write address during normal operation
        end
    end
end




reg [10:0] rd_data;

always @(posedge clk) begin
    if (reset) begin
        rd_data <= 0;
    end
    if (run && rd_en) begin
        rd_data <= div_table[rd_addr];
    end
end

    
    
    
    
    
    
endmodule
