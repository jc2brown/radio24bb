`timescale 1ps / 1ps


module tb_apb();
    

reg clk = 1'b1;
always #5000 clk <= !clk;    

reg reset = 1'b1;
initial #1000000 @(posedge clk) reset <= 1'b0;
    
    
reg penable = 0;
reg psel = 0;
reg [31:0] paddr = 0;
reg pwrite = 0;
reg [31:0] pwdata = 0;
reg [31:0] prdata = 0;
wire pready = 1;


reg [31:0] counter = 0;
always @(posedge clk) counter <= counter + 1;


    
reg [31:0] rd_data;




    
task apb_write (
    input [31:0] addr,
    input [31:0] wr_data    
);

// T1
@(posedge clk) begin
    psel <= 1;
    pwrite <= 1;
    penable <= 0;
    paddr <= addr;
    pwdata <= wr_data;
end

// T2
@(posedge clk) begin
    penable <= 1;
    // Expecting pready == 1 following this edge
end

// T3
@(posedge clk) begin   
    if (pready == 1) begin
        psel <= 0;
        penable <= 0;
        pwdata <= 0;
    end
end

endtask
    
    
    
    
    
task apb_read (
    input [31:0] addr,
    output [31:0] rd_data 
);

// T0
//@(posedge clk) begin
//    psel <= 0;
//    pwrite <= 0;
//    penable <= 0;
//end

// T1
@(posedge clk) begin
    psel <= 1;
    pwrite <= 1;
    penable <= 0;
    paddr <= addr;
end


// T2
@(posedge clk) begin
    penable <= 1;
    // Expecting pready == 1 following this edge
end


// T3
@(posedge clk) begin   
    if (pready == 1) begin
//        prdata <= data;
        psel <= 0;
        penable <= 0;
        pwdata <= 0;
    end
end

endtask
    
    
    
    
    
initial begin
    
    @(negedge reset);
    
    apb_write(32'h01234560, 32'hAABBCCDD);
    apb_write(32'h01234570, 32'hFFEEDDCC);
    apb_write(32'h01234570, 32'h00000001);
    
    apb_read(32'h01234570, rd_data);

end
    
    
    
endmodule
