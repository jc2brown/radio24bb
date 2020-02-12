
// This module converts an input stream with a sample rate fs < fsys to an output stream with a sample rate fsys
// by inserting linearly-interpolated samples.

// An error accumulator tracks the running discrepancy and applies corrections when output error exceeds +/-0.5 LSb.

// Some additional error is introduced when fs is not a divisor of fsys, but this error is small when fs << fsys.


module upsampler
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
	
	input signed [24:0] ratio


);






reg signed [INPUT_WIDTH-1:0] in_d1;
reg signed [INPUT_WIDTH-1:0] in_d2;


always @(posedge clk) begin
    if (in_valid) begin
        in_d1 <= in;
        in_d2 <= in_d1;
    end
end




wire signed [32:0] dy = (in_d1-in_d2)*ratio;

reg [31:0] input_sample_counter;

always @(posedge clk) begin
    if (reset) begin
        input_sample_counter <= 0;
    end
    else begin
        if (in_valid && input_sample_counter < 2) begin
            input_sample_counter <= input_sample_counter + 1;
        end
    end
end



reg signed [31:0] error_accum;

always @(posedge clk) begin
    if (reset) begin
        error_accum <= 0;
    end
    else begin
        if (input_sample_counter >= 2) begin
            if (apply_error_correction) begin
                error_accum <= 0;
            end
            else begin
//                error_accum <= error_accum + (out-(in_d1+in_d2)/2);
                error_accum <= error_accum + (out-(in_d1));
            end
        end
    end
end

reg signed [OUTPUT_WIDTH-1:0] out_d1;
always @(posedge clk) out_d1 <= out;



reg signed [31:0] error_accum_d1;
always @(*) error_accum_d1 <= error_accum;



reg signed [31:0] out_accum;
always @(*) out <= out_accum[31:(32-OUTPUT_WIDTH)];



reg signed [31:0] error_bound = 2**(32-OUTPUT_WIDTH) / 2; // Limit error to +/- 0.5 output LSb

wire apply_error_correction = 0;//(error_accum > error_bound || error_accum < -error_bound);



always @(posedge clk) begin
    if (reset) begin
        out_accum <= 0;
        out_valid <= 0;
    end
    else begin
        if (input_sample_counter >= 2) begin
            out_accum <= out_accum + dy - (apply_error_correction ? error_accum : 0);
            out_valid <= 1;
        end
        else begin
            out_accum <= in_d1 * 2**24;
        end
    end
end







endmodule
