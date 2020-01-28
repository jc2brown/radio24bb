    `timescale 1ps / 1ps


module tb_freq_meas();
    
    
    
    
reg clk = 1;
always #5000 clk <= !clk;

reg reset = 1;
initial #100000 reset <= 0;



reg test_clk = 1;
always #5333 test_clk <= !test_clk;

reg test_reset = 1;
initial #200000 test_reset <= 0;


reg fmeas_enable = 0;

initial begin

    @(negedge reset);
    
    repeat(2) begin
        #1000000 @(posedge clk) fmeas_enable <= 1;
        repeat (120) repeat(1000) repeat(1000) #1000; // Wait 120ms
        @(posedge clk) fmeas_enable <= 0;
    end
    
    #1000000 $finish();

end



wire [23:0] fmeas_count;


freq_meas dut (

    .clk(clk),
    .reset(reset),
    
    .test_clk(test_clk),
    .test_reset(test_reset),
    
    .fmeas_enable(fmeas_enable),
    .fmeas_count(fmeas_count)
    
);
    
    
    
    
    
    
    
endmodule
