`timescale 1ps / 1ps

module tb_fast_fir_filter(

    );
    
    

    
        
wire [31:0] sig_p;
    
gen_tone
#(

    // Tone
    .AMPL(127e-6),
    .FREQ(70e3),
    .SAMPLE_RATE(100e6),
    .PHASE_DELTA_INC(0.00003)
    /*
    // White noise
    .AMPL(0),
    .CM_NOISE_AMPL(127e-6),
    .SAMPLE_RATE(25e6)
    */
)
siggen_a 
(
    .sig_p_uv(sig_p)
);
    
    
    
    
    
reg clk = 1'b1;
always #5000 clk <= !clk;

reg reset = 1'b1;
initial #100000 reset <= 1'b0;
    

reg [10:0] valid_in = 'h0;
always @(posedge clk) valid_in <= valid_in + 1;

reg valid = 0;
initial begin
    #1000000 valid <= !reset; // 1 us from start of sim
end
    

wire signed [7:0] out;
wire signed [8:0] junk;
wire valid_out;


reg [24:0] cfg_din = 'h0;
reg cfg_ce = 1'b0;
    
wire signed [17:0] in = sig_p;
//wire [17:0] in = { {11{!sig_p[7]}}, {7{sig_p[7]}} };

fast_fir_filter
dut (    
    .reset(reset),
    .clk(clk),

    .cfg_clk(clk),
    .cfg_reset(reset),

    .cfg_din(cfg_din),
    .cfg_ce(cfg_ce),
    
    .len(),    

//    .in(&valid_in ? in : 0),
//    .valid_in(&valid_in),
    
    .in(in),
    .valid_in(valid),
    
    .out(out),
    .valid_out(valid_out)

);
    
    
    
real coef[1:21] = {                
      /*
	-0.00085693960, -0.0019427534, -0.00069509940, -0.0038411481, 
	-0.00083768112, -0.0083490695, -0.0012431629, -0.023540759, 
	-0.0016748405,	-0.20683919, 0.50280357, -0.20683919, 
	-0.0016748405,	 -0.023540759, -0.0012431629, -0.0083490695, 
	-0.00083768112,	 -0.0038411481, -0.00069509940, -0.0019427534,
	 -0.00085693960
	 */
	       
	       -0.0071699088, 0.017660398, -0.0065019968,
         -0.0083197947, -0.037167800, -0.081437413, -0.094770418, -0.041513285, 0.065617506,
         0.17013357, 0.21323928, 0.17013357, 0.065617506, -0.041513285, -0.094770418,
         -0.081437413, -0.037167800, -0.0083197947, -0.0065019968, 0.017660398, -0.0071699088
               
       
    /*
    0, 0, 0, 0, 0,
    0, 0, -0.15, -0.2, -0.3,
    0.3, 0.2, 0.15, 0, 0,
    0, 0, 0, 0, 0,
    0  */
       
    /*
    0,0,0,0,
    0,0,0,0,
    1,0,0,0,
    0,0,0,0,      
    0,0,0,0,
    0
    */
};
	
	

int fout = 0;

initial begin
    fout = $fopen("tb_fast_fir_filter.out", "wb");
//    repeat(1) repeat(1000) repeat(1000) #1000; // 1ms
//    $fclose(fout);
//    fout = 0;
end


    	
reg [7:0] x;
always @(posedge clk) if (valid_out) x <= out;


int sample_count = 0;

always @(posedge clk) begin
    if (valid_out && fout != 0) begin
        if (sample_count == 100000) begin
            $fclose(fout);
            $finish();
        end
        else begin
            $fwrite(fout, "%c", out);
            sample_count <= sample_count + 1;
        end
    end
end



	
integer i;    
    
initial begin

    @(negedge reset);
    
    for (i=1; i<=21; i=i+1) begin    
        @(posedge clk) begin
            cfg_din <= $rtoi(2**19 * coef[i]);
            cfg_ce <= 1;
        end
    end
    
    
    @(posedge clk) cfg_ce <= 1'b0;
/*
	0.052575624, 1.9468305, 0.052575624, -0.050807312, 0.047904049, -0.043930688,
	0.038975989, -0.033150630, 0.026584741, -0.019424993, 0.011831323, -0.0039733604
*/



end
    
    
    
    
    
endmodule
