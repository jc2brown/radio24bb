`timescale 1ps / 1ps


module tb_max19506(

    );
    
    
    
wire [31:0] siga_p_uv;
wire [31:0] siga_n_uv;
    
siggen
#(
    .AMPL(0.4),
    .FREQ(10.7e6),
    .VCM(0.9),
    .CM_NOISE_AMPL(0.2),
    .DM_NOISE_AMPL(0.05)
)
siggen_a 
(
    .sig_p_uv(siga_p_uv),
    .sig_n_uv(siga_n_uv)
);
    
    
  
    
reg clk = 1'b1; 
always #5000 clk <= !clk;

wire [7:0] doa;
wire [7:0] dob;
 


max19506 dut(
    .clk(clk),
    .ina_p_uv(siga_p_uv),
    .ina_n_uv(siga_n_uv),
    .doa(doa)
);
    
endmodule
