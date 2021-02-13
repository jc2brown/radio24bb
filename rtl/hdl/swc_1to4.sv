
// Input: DW bits per clock
// Output: 4*DW bits 

module swc_1to4
#(
    parameter DW = 0 // Set in parent module
) 
(

    input wire clk,
    input wire reset_n, 

    input wire [DW-1:0] data_in,
    input wire valid_in,

    output reg [4*DW-1:0] data_out,
    output reg valid_out

);


reg [DW-1:0] byte_buf [2:0];

reg [1:0] state;


always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        byte_buf[0] <= {DW{1'b0}};
        byte_buf[1] <= {DW{1'b0}};
        byte_buf[2] <= {DW{1'b0}};
        data_out <= 0;
        valid_out <= 0;
        state <= 0;
    end
    else begin
        if (valid_in) begin
            if (state == 0) begin
                // No bytes in buffer, 1 incoming, 0 outgoing   
                byte_buf[0] <= data_in;
                valid_out <= 0;
                state <= 1;
            end
            else if (state == 1) begin
                // 1 byte in buffer, 1 incoming, 0 outgoing
                byte_buf[1] <= data_in;
                valid_out <= 0;
                state <= 2;
            end
            else if (state == 2) begin
                // 2 bytes in buffer, 1 incoming, 0 outgoing
                byte_buf[2] <= data_in;
                valid_out <= 0;
                state <= 3;
            end
            else if (state == 3) begin
                // 3 bytes in buffer, 1 incoming, 4 outgoing
                data_out <= { data_in, byte_buf[2], byte_buf[1], byte_buf[0] };
                valid_out <= 1;
                state <= 0;
            end
        end
        else begin
             valid_out <= 0;
        end
    end
end




endmodule