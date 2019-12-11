`timescale 1ps / 1ps


module tb_siggen(

    );
    



wire [31:0] siga_p_uv;
wire [31:0] siga_n_uv;
    
siggen
#(
    .AMPL(0.4),
    .FREQ(1e6),
    .VCM(0.01),
    .CM_NOISE_AMPL(0.01),
    .DM_NOISE_AMPL(0.01)
)
siggen_a 
(
    .sig_p_uv(siga_p_uv),
    .sig_n_uv(siga_n_uv)
);
    
    
  
    
reg clk = 1'b1; 
always #5000 clk <= !clk;



    
    
endmodule
