`timescale 1ps / 1ps

module tb_cross_interp(

    );
    
    


reg clk = 1;
always #5000 clk <= !clk;

reg reset = 1;
always #50000 @(posedge clk) reset <= 0;


wire [31:0] if_in_uv;
    
siggen
#(
    .AMPL(127e-6),
    .FREQ(10.7e6),
    .SAMPLE_RATE(100000000)
)
siggen_in_l 
(
    .sig_p_uv(if_in_uv)
);






reg run = 0;

reg div_table_wr_en = 0;
reg [10:0] div_table_wr_data = 0;

integer i;
initial begin
    
    for (i = 1; i < 2048; i = i + 1) begin
        @(posedge clk) begin
            div_table_wr_en <= 1;
            div_table_wr_data <= 2048 / i;
        end
    end 

    @(posedge clk) begin
        div_table_wr_en <= 0;
    end
        
    @(posedge clk) begin
        run <= 1;
    end


end

//wire [7:0] vin;
wire [7:0] vref = 0;



wire [7:0] t;
wire t_valid;
    

cross_interp dut (
    
    .clk(clk),
    .reset(reset),
    
    .run(run),
    
    .div_table_wr_en(div_table_wr_en),
    .div_table_wr_data(div_table_wr_data),
    
    .vin(if_in_uv),
    .vref(vref),
    
    // 2 cycle latency
    .t(t),
    .t_valid(t_valid)
    
);
    
    
reg [7:0] count = 0;
wire [15:0] timestamp = {count, t};
reg [15:0] timestamp_d1 = 0;

reg [15:0] period;
    
    
    
    
always @(posedge clk) begin
    count <= count + 1;
    if (t_valid) begin
        timestamp_d1 <= timestamp;
        period <= timestamp - timestamp_d1;
        //count <= 0;
    end
end    
    
    
reg [21:0] filt = 0;
always @(posedge clk) if (run && t_valid) filt <= (63*filt+period*64)/64;
    
reg [21:0] filt2 = 0;
always @(posedge clk) if (run && t_valid) filt2 <= (63*filt2+filt)/64;
    
    
endmodule
