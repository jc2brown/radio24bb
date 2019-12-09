`timescale 1ps / 1ps


module led_ds(
);   
    
    
reg clk = 1'b1;
always #5000 clk <= !clk;

wire out;


ddac
#(
    .DEPTH(8)
)
ddac_inst
(
    .clk(clk),
    .count(2),
    .out(out)
);   
    



    
    
endmodule
