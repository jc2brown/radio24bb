
module i2s_ctrl (

    input clk,
    input reset,
    
    output mclk,
    output wclk,
    output bclk

);


// clk = 100 MHz
// count[0] = 50 MHz
// count[1] = 25 MHz
// count[2] = 12.5 MHz
// count[3] = 6.25 MHz
// count[4] = 3.125 MHz
// count[5] = 1.5625 MHz
// count[6] = 781.25 kHz
// count[7] = 390.625 kHz
// count[8] = 195.3125 kHz
// count[9] = 97.65625 kHz
// count[10] = 48.828125 kHz


reg [31:0] count = 'h0;    

always @(posedge clk) begin
    if (reset) begin
        count <= 0;
    end
    else begin
        count <= count + 1;
    end
end



assign mclk = count[2];
assign bclk = count[5];
assign wclk = count[10];




endmodule

