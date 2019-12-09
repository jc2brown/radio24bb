`timescale 1ps / 1ps



module max19506(

    input clk,
    
    input wire [31:0] ina_p_uv,
    input wire [31:0] ina_n_uv,
           
    input wire [31:0] inb_p_uv,
    input wire [31:0] inb_n_uv,
    
    output reg [7:0] doa, 
    output wire dclka,
    output reg dora,
    
    output reg [7:0] dob,
    output wire dclkb,
    output reg dorb    
    

);


function [31:0] min(input [31:0] a, input [31:0] b);
    return ((signed'(a) < signed'(b)) ? a : b);
endfunction

function [31:0] max(input [31:0] a, input [31:0] b);
    return ((signed'(a) > signed'(b)) ? a : b);
endfunction


wire [31:0] ina_uv = ina_p_uv - ina_n_uv;
wire [31:0] inb_uv = inb_p_uv - inb_n_uv;


wire [31:0] ina_lim_uv = max(min(ina_uv, 750000), -750000);
wire [31:0] inb_lim_uv = max(min(inb_uv, 750000), -750000);
    

wire [31:0] vpk_uv = 750000; 
wire [31:0] vref_uv = 1250000; 
wire [7:0] adca = (signed'(127) * signed'(ina_lim_uv)) / signed'(vpk_uv);

always @(posedge clk) begin
    doa <= adca;
    dora <= (signed'(ina_uv) < -750000 || signed'(ina_uv) > 750000);
end

assign dclka = clk;
assign dclkb = clk;

always @(posedge clk) begin
    dob <= inb_uv[31:24];
end


    
    
    
endmodule
