`timescale 1ps / 1ps


module gen_fm
#(
     parameter real AMPL = 1.0,
     parameter real FREQ = 10e6,   
     parameter real VCM = 0,
     parameter real CM_NOISE_AMPL = 0.0,
     parameter real DM_NOISE_AMPL = 0.0,
     parameter real SIG_CLK_PER = 10000, // 100MSps, in ps   //1e12 / (51*FREQ), // 51 samples per signal period
     parameter real NOISE_CLK_PER = SIG_CLK_PER / 3 // 3 noise samples per signal sample         
     //parameter real 
)
(
    output wire [31:0] sig_p_uv,
    output wire [31:0] sig_n_uv
);
    
    
    
    
    
    
    
reg sigclk = 1'b0;
always #(SIG_CLK_PER/2) sigclk <= !sigclk;
//always #(5000) sigclk <= !sigclk;

reg noiseclk = 1'b0;
always #(NOISE_CLK_PER/2) noiseclk <= !noiseclk;

reg reset = 1'b1;
initial #10000 @(posedge noiseclk) reset <= 1'b0;

reg enable = 1'b0;
initial #100000 @(posedge noiseclk) enable <= 1'b1;



wire [16:0] cm_noise_raw;
wire [16:0] dm_p_noise_raw;
wire [16:0] dm_n_noise_raw;

prbs #(
    .SEED(23'b1111_1111_1111_0000_0000_001)
) cm_noisegen (
    .clk(noiseclk),                 
    .reset(reset),             
    .en(enable),                  
    .init(0),                
    .data(cm_noise_raw)
);

prbs #(
    .SEED(23'b1111_1111_1111_0000_0000_010)
) dm_n_noisegen (
    .clk(noiseclk),               
    .reset(reset),             
    .en(enable),                  
    .init(0),                
    .data(dm_n_noise_raw)
);
    
prbs #(
   .SEED(23'b1111_1111_1111_0000_0000_100)
) dm_p_noisegen (
    .clk(noiseclk),               
    .reset(reset),             
    .en(enable),                  
    .init(0),                
    .data(dm_p_noise_raw)
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



real phase = 0;
real phasedelta = 2*3.1415*FREQ/100e6 /**1e-6*/; // 10.7MHz @ 1000ps / sample

real phase2 = 0;
real phasedelta2 = 2*3.1415*FREQ/(100*100e6) /**1e-6*/; // 10.7MHz @ 1000ps / sample

always @(posedge sigclk) phase <= phase + phasedelta + (phasedelta/50)*$sin(phase2);
always @(posedge sigclk) phase2 <= phase2 + phasedelta2;

wire [31:0] sig_ampl_uv = AMPL * 1e6;   //400000; //375000;
wire [31:0] sig_uv = sig_ampl_uv*$sin(phase);


wire [31:0] cm_uv = VCM * 1e6;

assign sig_p_uv = (cm_uv + sig_uv) + cm_noise_uv + dm_p_noise_uv;
assign sig_n_uv = (cm_uv - sig_uv) + cm_noise_uv + dm_n_noise_uv;





    
    
endmodule
