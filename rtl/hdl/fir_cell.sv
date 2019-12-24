

module fir_cell(
    
    input clk,
    input reset,
    
    input valid_in,
    input valid_out,
    
    input signed [24:0] mult_coef,
    input signed [17:0] mult_in,
    input signed [47:0] acc_in,
    output signed [47:0] result
                       
);
    

/*


reg [2:0] valid_sr;
always @(posedge clk) begin
    if (reset) begin
        valid_sr <= 'h0;
    end
    else begin
        valid_sr <= {valid_sr[1:0], valid_in};
    end
end 

assign valid_out = valid_sr[2];


MACC_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "7SERIES" 
    .LATENCY(3),        // Desired clock cycle latency, 1-4
    .WIDTH_A(25),       // Multiplier A-input bus width, 1-25
    .WIDTH_B(18),       // Multiplier B-input bus width, 1-18
    .WIDTH_P(48)        // Accumulator output bus width, 1-48
) MACC_MACRO_inst (

    .CLK(clk),   // 1-bit positive edge clock input
    .RST(reset),    // 1-bit input active high reset
    
    .A(mult_coef),     // MACC input A bus, width determined by WIDTH_A parameter
    .B(mult_in),     // MACC input B bus, width determined by WIDTH_B parameter
    
    .P(result),     // MACC output bus, width determined by WIDTH_P parameter
    
    .ADDSUB(1'b1), // 1-bit add/sub input, high selects add, low selects subtract
    .CARRYIN(1'b0), // 1-bit carry-in input to accumulator
    
    .CE(1'b1),     // 1-bit active high input clock enable
//    .CE(valid_in),     // 1-bit active high input clock enable
//    .LOAD(1'b1), // 1-bit active high input load accumulator enable
    .LOAD(valid_sr[0]), // 1-bit active high input load accumulator enable
    .LOAD_DATA(acc_in) // Load accumulator input data, width determined by WIDTH_P parameter
);

*/




//
// Stage 1
//

reg valid_d1;
always @(posedge clk) valid_d1 <= valid_in;

reg signed [17:0] mult_d1;
always @(posedge clk) if (valid_in) mult_d1 <= mult_in;

reg signed [24:0] coef_d1;
always @(posedge clk) if (valid_in) coef_d1 <= mult_coef;

reg signed [47:0] acc_d1;
always @(posedge clk) if (valid_in) acc_d1 <= acc_in;


// 
// Stage 2
//

reg valid_d2;
always @(posedge clk) valid_d2 <= valid_d1;

reg signed [47:0] acc_d2;
always @(posedge clk) if (valid_d1) acc_d2 <= acc_d1;

reg signed [47:0] product_d2;
always @(posedge clk) if (valid_d1) product_d2 <= mult_d1 * coef_d1;


// 
// Stage 3
//

reg valid_d3;
always @(posedge clk) valid_d3 <= valid_d2;

reg signed [47:0] sum_d3;
always @(posedge clk) if (valid_d2) sum_d3 <= product_d2 + acc_d2;


assign result = sum_d3;
assign valid_out = valid_d3;




    
endmodule
