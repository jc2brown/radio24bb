`timescale 1ps / 1ps


module fm_demod (

    input clk,
    input reset,
    
    input run,
    
    input [31:0] vco_gain,
    input [31:0] vco_bias,
    
    input fin,
    output reg [31:0] fm

);
    

wire fref;

//
// CHARGE PUMP + LOOP FILTER
//

wire cp_up = fref && !fin;
wire cp_dn = !fref && fin;

reg fin_d1;
always @(posedge clk) fin_d1 <= fin;

reg fref_d1;
always @(posedge clk) fref_d1 <= fref;



reg [31:0] t = 0;
always @(posedge clk) t <= t + 1;

reg [31:0] fin_rise = 0;
//always @(posedge clk) if (fin && !fin_d1) fin_rise <= t;

reg [31:0] fin_rise_d1 = 0;
//always @(posedge clk) if (fin && !fin_d1) fin_rise_d1 <= fin_rise;



reg [31:0] fin_period_d1 = 0;
reg [31:0] fin_period = 0;
//always @(posedge clk) if (fin && !fin_d1) fin_period <= signed'(fin_period) + (signed'(fin_rise) - signed'(fin_rise_d1));


reg [31:0] af = 0;

always @(posedge clk) begin
    if (fin && !fin_d1) begin
        fin_rise <= t;
        fin_rise_d1 <= fin_rise;
        fin_period <= /*signed'(fin_period) +*/ (signed'(t) - signed'(fin_rise));
        fin_period_d1 <= fin_period;
        af <= signed'(af) + (signed'(fin_period) - signed'(fin_period_d1));
    end

end

//wire [31:0] afi = signed'(af)*signed'(100  
/*


reg [31:0] fref_rise = 0;
always @(posedge clk) fref_rise <= t;

reg [31:0] fref_rise_d1 = 0;
always @(posedge clk) fref_rise_d1 <= fref_rise;

wire [31:0] fref_period = fref_rise - fref_rise_d1;



*/




/*

always @(posedge clk) begin
    if (reset) begin
        fm <= 'h0;
    end
    else begin  
        if (run) begin
        
            
        
            if ((fin && !fin_d1) begin
                if (fm == 0) begin
                    fm <= 
            
        
        
            if ((fin && !fin_d1) || (fref && !fref_d1)) begin
                if (cp_up) begin
                    fm <= signed'(fm) + signed'(vco_gain);
                end
                else if (cp_dn) begin
                    fm <= signed'(fm) - signed'(vco_gain);
                end
            end
        
        end
        else begin
            fm = 0;
        end
    end
end
*/


//
// VCO
//
    
    
reg [31:0] accum;

always @(posedge clk) begin
    if (reset) begin
        accum <= 'h0;
    end
    else begin  
        if (run) begin
            accum <= signed'(accum) + signed'(vco_bias) + signed'(fm);
        end
    end
end
    
assign fref = accum[31];




    
endmodule
