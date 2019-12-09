`timescale 1ps / 1ps

module max19506_serial_if(

    input clk,
    input reset,
    
    output reg max19506_sclk,
    output reg max19506_sdin,
    output reg max19506_spen,
    
    input shdn

);
    
    
    
always @(posedge clk) begin

    if (reset) begin
        max19506_sclk <= 1'b0;
        max19506_sdin <= 1'b0;
        max19506_spen <= 1'b0;
    end
    else begin
       max19506_sclk <= !max19506_sclk;
       max19506_sdin <= !max19506_sdin;
       max19506_spen <= !max19506_spen;
    
    end

end
    
    
endmodule
