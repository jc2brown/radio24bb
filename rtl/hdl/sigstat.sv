
module sigstat
#(
    parameter WIDTH = 32
) (

    input clk,
    
    input enable,
    input reset,    
    
    input [WIDTH-1:0] sig,
    input sig_valid,
    input [WIDTH-1:0] limit,
    output reg [WIDTH-1:0] min,
    output reg [WIDTH-1:0] max,
    output reg [31:0] count    

);


always @(posedge clk) begin
    if (reset) begin
        min <= {{1{1'b0}}, {(WIDTH-1){1'b1}}};
        max <= {{1{1'b1}}, {(WIDTH-1){1'b0}}};
        count <= 0; 
    end
    else begin
        if (enable && sig_valid && (limit == 0 || count < limit)) begin
            count <= count + 1;
            if (signed'(sig) < signed'(min)) begin
                min <= sig;
            end
            if (signed'(sig) > signed'(max)) begin
                max <= sig;
            end            
        end
    end 
end



endmodule
