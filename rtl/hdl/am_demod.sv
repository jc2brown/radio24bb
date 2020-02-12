

// This module performs basic incoherent AM demodulation on an input data stream sampled at a rate fs. 
// The input signal must be an amplitude-modulated carrier with frequency DC < fc < fs/2 and a modulation depth not greater than 100%,
// the output is a stream of samples emitted at a rate of 2*fc representing the carrier's peak-to-peak amplitude during the previous half-cycle. 

// The algorithm used in this module measures amplitude by detecting crests in the carrier signal.
// Any DC offset on the carrier is implicitly and gracefully rejected with no impact on the output signal.

// TODO: maybe switch to a zero/DC crossing method? Might be less error-prone than crest detection


module am_demod 
#(
	parameter INPUT_WIDTH = 0,
	parameter OUTPUT_WIDTH = 0
)
(

    input clk,
    input reset,

	input signed [INPUT_WIDTH-1:0] in,
	input in_valid,

	output reg signed [OUTPUT_WIDTH-1:0] out,
	output reg out_valid,

	input [31:0] oversample_ratio


);



reg signed [INPUT_WIDTH-1:0] dc;

reg signed [INPUT_WIDTH-1:0] in_d0;
reg signed [INPUT_WIDTH-1:0] in_d1;
reg signed [INPUT_WIDTH-1:0] in_d2;

always @(posedge clk) begin

    if (reset) begin
        in_d0 <= 0;
        in_d1 <= 0;
        in_d2 <= 0;
    end
    else if (in_valid) begin
        in_d0 <= in;
        in_d1 <= in_d0;
        in_d2 <= in_d1;
    end
end


wire signed [INPUT_WIDTH-1:0] diff1 = (in_d0-in_d1);
wire signed [INPUT_WIDTH-1:0] diff2 = (in_d1-in_d2);


reg upper_crest;
reg lower_crest;


reg positive_going = 0;
always @(posedge clk) begin
    upper_crest <= 0;
    lower_crest <= 0;
    if (in_valid) begin
        if (positive_going && ( (diff1 < 0 && diff2 <= 0) || (diff1 <= 0 && diff2 < 0) ))  begin    //|| (!positive_going && diff1 > 0 && diff2 > 0) ) begin
            positive_going <= 0;
            upper_crest <= 1;
        end
        if (!positive_going && ( (diff1 > 0 && diff2 >= 0) || (diff1 >= 0 && diff2 > 0) )) begin    //|| (!positive_going && diff1 > 0 && diff2 > 0) ) begin
            positive_going <= 1;
            lower_crest <= 1;
        end
                
    end
end


reg signed [INPUT_WIDTH-1:0] upper_peak;
reg signed [INPUT_WIDTH-1:0] lower_peak;

wire [INPUT_WIDTH-1:0] envelope_amplitude = upper_peak - lower_peak;



reg signed [INPUT_WIDTH-1:0] highest;
reg signed [INPUT_WIDTH-1:0] lowest;


always @(posedge clk) begin
    if (reset) begin
        highest <= (2**(INPUT_WIDTH-1))-1; // Most positive possible value
        lowest <= -(2**INPUT_WIDTH); // Most negative possible value
        upper_peak <= 0;
        lower_peak <= 0;
    end
    else begin
        if (upper_crest) begin
            upper_peak <= highest;
            highest <= -(2**INPUT_WIDTH); // Most negative possible value
        end
        else begin
            highest <= (in_d0 > highest) ? in_d0 : highest;
        end
        
        if (lower_crest) begin
            lower_peak <= lowest;
            lowest <= (2**(INPUT_WIDTH-1))-1; // Most positive possible value
        end
        else begin
            lowest <= (in_d0 < lowest) ? in_d0 : lowest;
        end
    end
end




reg [31:0] accum;


reg [31:0] oversample_counter;


wire [OUTPUT_WIDTH-1:0] extended_envelope_amplitude = {{(OUTPUT_WIDTH-INPUT_WIDTH){1'b0}}, envelope_amplitude};

always @(posedge clk) begin
    out_valid <= 0;
    if (reset) begin
        oversample_counter <= 0;
        accum <= 0;
        out <= 0;
    end
    else if (upper_crest || lower_crest) begin
        if (oversample_counter == oversample_ratio-1) begin
            oversample_counter <= 0;
            out <= { 
                (accum + extended_envelope_amplitude)/ oversample_ratio,
                {(OUTPUT_WIDTH-INPUT_WIDTH){1'b0}}
            };
            out_valid <= 1;
            accum <= 0;
        end
        else begin
            oversample_counter <= oversample_counter + 1;
            accum <= accum + envelope_amplitude;
        end
    end
end





endmodule