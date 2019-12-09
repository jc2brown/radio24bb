`timescale 1ps / 1ps


module max5851(

    input wire [7:0] dia,
    input wire dclka,
    
    input wire [7:0] dib,
    input wire dclkb
    
);



reg [7:0] daca;
reg [7:0] dacb;

always @(posedge dclka) begin
    daca <= dia;
    dacb <= dib; 
end



    
    
endmodule

