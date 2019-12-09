
module prbs #(
               parameter POLY_LENGTH = 23,
               parameter POLY_TAP = 18,
               parameter [POLY_LENGTH-1:0] SEED = 23'b1111_1111_1111_0000_0000_000,
               parameter WIDTH = 17
               )
  (
    input clk,                 // Clock
    input reset,             // Asynchronous reset, active low
    input en,                  // Enable, active high
    input init,                // Initialization, active high
    output [WIDTH-1:0] data    // Output data, {MSB,...,LSB}
   );

  reg [WIDTH-1:0]               data_q;
  reg [POLY_LENGTH-1:0]         lfsr_q;
  wire [WIDTH+POLY_LENGTH-1:0]  lfsr_c;

  assign lfsr_c[POLY_LENGTH-1:0] = lfsr_q;

// Internal registers
  always @(posedge clk) begin
    if(reset) begin
      data_q <= {WIDTH{1'b0}};
      lfsr_q <= SEED;
    end else begin
      if (en) begin
        data_q <= lfsr_c[WIDTH+POLY_LENGTH-1:POLY_LENGTH];
        lfsr_q <= init ? SEED : lfsr_c[WIDTH+POLY_LENGTH-1:WIDTH];
      end
    end
  end

// Generation of combinational logic  
  genvar i;
  generate
    for(i=POLY_LENGTH; i<WIDTH+POLY_LENGTH; i=i+1) begin:gen_prbs
      assign lfsr_c[i] = lfsr_c[i-POLY_TAP] ^ lfsr_c[i-POLY_LENGTH];
    end
  endgenerate

// Output assignment
  genvar y;
  generate
    for(y=0;y<WIDTH;y=y+1) begin:gen_reconnect
      assign data[y] = data_q[WIDTH-1-y];
    end
  endgenerate

endmodule // s3_prbs
