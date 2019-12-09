
module cross_interp (
    
    input clk,
    input reset,
    
    input run,
    
    input div_table_wr_en,
    input [10:0] div_table_wr_data,
    
    input [7:0] vin,
    input [7:0] vref,
    
    // 2 cycle latency
    output reg [7:0] t,
    output reg t_valid
    
);




// This module uses interpolation to estimate the precise time at which a signal crosses some level vref (typically 0) given a pair of samples from an ADC

// The function which interpolates a point (x, y) between two points (x0, y0) and (x1, y1) is
//     y(x) = (y1-y0) * (x-x0) / (x1-x0)

// Two samples v0 and v1 can be represented as points (t0, v0) and (t1, v1) where t1=t0+1

// When v0 <= vref and v1 > vref, the point (t, v=vref) is the crossing point where t includes the interpolated fraction of a sample period

// From the interpolation function above
//     t = (t1-t0) * (vref-v0) / (v1-v0)
     
// And since t1-t0=1
//     t = (vref-v0) / (v1-v0)

// To implement the required division, a lookup table div_table stores the following: 
//     for i : 1..2047:
//         div_table[i] = 2048 / i  

// So the interpolation can be realized with
//     t = (vref-v0) * div_table[v1-v0] / 2048
 
 

    

reg [10:0] div_table [0:2047];
reg [10:0] wr_addr = 0;

always @(posedge clk) begin
    if (run) begin
        wr_addr <= 0;
    end 
    else if (div_table_wr_en) begin
        div_table[wr_addr] <= div_table_wr_data;
        wr_addr <= wr_addr + 1;        
    end
end


reg [7:0] v0;
always @(posedge clk) v0 <= vin;
wire [7:0] v1 = vin;

// 1st stage - div lookup

reg [7:0] v0_d1 = 0;
reg [7:0] v1_d1 = 0;
reg [7:0] vref_d1 = 0;
reg [10:0] quotient_d1; // _d1 suffix added to denote alignment with y0_d1 and y1_d1
reg quotient_valid;
wire [10:0] dv = v1-v0; 

always @(posedge clk) begin
    quotient_valid <= 0;
    if (signed'(v0) <= signed'(vref) && signed'(v1) > signed'(vref)) begin
        quotient_d1 <= div_table[dv/*<<3*/]; // shift (v1-v0)[7:0] up to [10:3]
        quotient_valid <= 1;
        v0_d1 <= v0;   
        v1_d1 <= v1;  
        vref_d1 <= vref;
    end
end


// 2nd stage -  multiplier

reg [39:0] product_d2 = 0;
reg product_valid = 0;

always @(posedge clk) begin
    product_valid <= 0;
    if (quotient_valid) begin
        product_d2 <= (vref_d1-v0_d1) * quotient_d1;
        product_valid <= 1;
    end
end

assign t = product_d2[10:3];
assign t_valid = product_valid;

endmodule
