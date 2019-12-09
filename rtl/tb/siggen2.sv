`timescale 1ps / 1ps


module siggen2 
#(
     parameter real AMPL = 1.0,
     parameter real FREQ = 10e6,   
     parameter real VCM = 0,
     parameter real CM_NOISE_AMPL = 0.0,
     parameter real DM_NOISE_AMPL = 0.0,
//     parameter real SIG_CLK_PER = 1e12 / (51*FREQ), // 51 samples per signal period
//     parameter real NOISE_CLK_PER = SIG_CLK_PER / 3 // 3 noise samples per signal sample   
     parameter real SAMPLE_RATE = 1e6 
)
(
    output wire [31:0] sig_p_uv,
    output wire [31:0] sig_n_uv
);
    
    
    
localparam real SIG_CLK_PER = 1e12 / SAMPLE_RATE;
localparam real NOISE_CLK_PER = SIG_CLK_PER / 4.0;
    
    
    
reg sigclk = 1'b0;
always #(SIG_CLK_PER/2) sigclk <= !sigclk;

reg noiseclk = 1'b0;
always #(NOISE_CLK_PER/2) noiseclk <= !noiseclk;

reg reset_n = 1'b0;
initial #10000 @(posedge noiseclk) reset_n <= 1'b1;

reg enable = 1'b0;
initial #100000 @(posedge noiseclk) enable <= 1'b1;



wire [16:0] cm_noise_raw;
wire [16:0] dm_p_noise_raw;
wire [16:0] dm_n_noise_raw;

s3_prbs #(
    .SEED(23'b1111_1111_1111_0000_0000_001)
) cm_noisegen (
    .clk_i(noiseclk),                 
    .reset_n_i(reset_n),             
    .en_i(enable),                  
    .init_i(0),                
    .data_o(cm_noise_raw)
);

s3_prbs #(
    .SEED(23'b1111_1111_1111_0000_0000_010)
) dm_n_noisegen (
    .clk_i(noiseclk),               
    .reset_n_i(reset_n),             
    .en_i(enable),                  
    .init_i(0),                
    .data_o(dm_n_noise_raw)
);
    
s3_prbs #(
   .SEED(23'b1111_1111_1111_0000_0000_100)
) dm_p_noisegen (
    .clk_i(noiseclk),               
    .reset_n_i(reset_n),             
    .en_i(enable),                  
    .init_i(0),                
    .data_o(dm_p_noise_raw)
);



reg [31:0] cm_noise_uv;
reg [31:0] dm_p_noise_uv;
reg [31:0] dm_n_noise_uv;

     
     
wire [31:0] cm_noise_ampl_uv   = CM_NOISE_AMPL * 1e6;
wire [31:0] dm_p_noise_ampl_uv =  DM_NOISE_AMPL * 1e6;
wire [31:0] dm_n_noise_ampl_uv =  DM_NOISE_AMPL * 1e6;

always @* begin
    cm_noise_uv = ((cm_noise_ampl_uv * signed'(cm_noise_raw)) / 2**16);// - cm_noise_ampl_uv);
    dm_p_noise_uv = ((dm_p_noise_ampl_uv * signed'(dm_p_noise_raw)) / 2**16);// - dm_p_noise_ampl_uv);
    dm_n_noise_uv = ((dm_n_noise_ampl_uv * signed'(dm_n_noise_raw)) / 2**16);// - dm_n_noise_ampl_uv);
end


localparam real SAMPLES_PER_PERIOD = SAMPLE_RATE / FREQ;

real phase = 0;
real phasedelta = 2*3.1415/SAMPLES_PER_PERIOD;
always @(posedge sigclk) phase <= phase + phasedelta;

wire [31:0] sig_ampl_uv = AMPL * 1e6;   //400000; //375000;
wire [31:0] sig_uv = signed'(sig_ampl_uv) * $sin(phase);


wire [31:0] cm_uv = VCM * 1e6;

assign sig_p_uv = (cm_uv + sig_uv) + cm_noise_uv + dm_p_noise_uv;
assign sig_n_uv = (cm_uv - sig_uv) + cm_noise_uv + dm_n_noise_uv;





    
    
endmodule
