

module fast_fir_cell(
    
    input clk,
    input reset,
    
    input valid_in,
    input valid_out,
    
    input signed [24:0] mult_coef,
    input signed [17:0] mult_in,
    output signed [47:0] result
                       
);
    



//
// Stage 1
//

reg valid_d1;
always @(posedge clk) valid_d1 <= valid_in;

reg signed [17:0] mult_d1;
always @(posedge clk) if (valid_in) mult_d1 <= mult_in;

reg signed [24:0] coef_d1;
always @(posedge clk) if (valid_in) coef_d1 <= mult_coef;


// 
// Stage 2
//

reg valid_d2;
always @(posedge clk) valid_d2 <= valid_d1;

reg signed [47:0] product_d2;
always @(posedge clk) if (valid_d1) product_d2 <= mult_d1 * coef_d1;



assign result = product_d2;
assign valid_out = valid_d2;




    
endmodule
