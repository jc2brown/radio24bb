`timescale 1ns / 1ps


module tb_divlut(

    );
    
    
    
reg clk = 1;
always #5000 clk <= !clk;

reg reset = 1;
initial #50000 @(posedge clk) reset = 0;    
    
    
reg run = 0;
    
//reg [10:0] wr_data = 0;
reg wr_en = 0;

reg [10:0] rd_addr = 0;
reg rd_en = 0;
wire [10:0] rd_data; 
wire rd_data_valid;

reg [31:0] wr_data_big;

wire [10:0] wr_data = wr_data_big>>6;


integer i;
initial begin

    @(negedge reset);
    
    
    for (i=1; i<2047; i=i+1) begin
        @(posedge clk) begin
            wr_en <= 1;
            wr_data_big <= ((2048*65536) / (2048+(i-1024)));            
        end
    end
    
    @(posedge clk) begin
        wr_en <= 0;
    end
    
    @(posedge clk) begin
        run <= 1;
    end
    
    

    @(posedge clk) begin
        rd_en <= 1;
        for (i=1; i<2048; i=i+1) begin
            @(posedge clk) begin
                rd_addr <= i;
                rd_en <= 1;
            end
        end 
        
        @(posedge clk) begin
            rd_en <= 0;
        end
    end



    $finish();

end




divlut dut (

    .clk(clk),
    .reset(reset),
    .run(run),
    .wr_data(wr_data),
    .wr_en(wr_en),
    .rd_addr(rd_addr),
    .rd_en(rd_en),
    .rd_data(rd_data),
    .rd_data_valid(rd_data_valid)

);
    

    
    
    
    
endmodule
