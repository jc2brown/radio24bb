
module i2s_ctrl (

    input clk,
    input reset,
    
    input [1:0] aud_rate,
    
    output mclk,
    output reg wclk,
    output reg bclk,
    output reg mpx_sel

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


// If clk == 100MHz
//assign mclk = count[2];
//assign bclk = count[5];
//assign wclk = count[10];

// If clk == 9.728MHz

assign mclk = clk;

always @(*) begin

    mpx_sel = count[7];
    
    // 38kHz
    if (aud_rate == 0) begin        
        bclk = count[2];
        wclk = count[7];
    end
        
    // 72kHz
    else if (aud_rate == 1) begin        
        bclk = count[1];
        wclk = count[6];
    end
                
    // 152kHz
    else if (aud_rate == 2) begin        
        bclk = count[0];
        wclk = count[5];
    end

end


endmodule

