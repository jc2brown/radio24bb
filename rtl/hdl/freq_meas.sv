`timescale 1ps / 1ps



// If fmeas_count is stuck at -1 (AKA 2^24-1), test_reset is probably asserted
// If fmeas_count is stuck at 0, test_clk is probably not toggling

module freq_meas(

    input clk,
    input reset,  // clk domain
    
    input test_clk,
    input test_reset,
    
    input fmeas_enable,         // clk domain
    output [23:0] fmeas_count   // clk domain
    
);
    
    
    
reg [23:0] ref_count; 

// Max count = 2^24-1 = ~16M -> round down to 10M -> 100ms @ pl_clk0 = 100MHz
localparam [23:0] max_ref_count = 100_000;


reg fmeas_enable_d1;
always @(posedge clk) fmeas_enable_d1 <= fmeas_enable;



always @(posedge clk) begin
    if (reset) begin
        ref_count <= max_ref_count;
    end
    // Reset ref_count when fmeas_enable rises
    else if (fmeas_enable && !fmeas_enable_d1) begin
        ref_count <= 0;
    end
    else if (ref_count != max_ref_count) begin
        ref_count <= ref_count + 1;
    end
end
    
    
wire ref_count_enabled = ref_count != max_ref_count; 
    
    
wire enable_test_count;

 
xpm_cdc_single #(
    .DEST_SYNC_FF(2),  
    .INIT(1),           
    .INIT_SYNC_FF(0),  
    .SIM_ASSERT_CHK(0) 
)
enable_cdc (
    .src_clk(clk),
    .src_in(ref_count_enabled),  
    .dest_clk(test_clk),
    .dest_out(enable_test_count)
);
    
    
    
reg enable_test_count_d1;
always @(posedge test_clk) enable_test_count_d1 <= enable_test_count;

    
reg [23:0] test_count = 0;
    
    
always @(posedge test_clk) begin
    if (test_reset) begin
        test_count <= -1;
    end
    else begin
        if (enable_test_count && !enable_test_count_d1) begin
            test_count <= 0;
        end
        else if (enable_test_count) begin
            test_count <= test_count + 1;
        end    
    end
end    
    
    
    
xpm_cdc_gray #(
   .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
   .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   .REG_OUTPUT(0),            // DECIMAL; 0=disable registered output, 1=enable registered output
   .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
   .WIDTH(24)                 // DECIMAL; range: 2-32
)
xpm_cdc_gray_inst (
   .dest_out_bin(fmeas_count), 
   .dest_clk(clk),       
   .src_clk(test_clk),         
   .src_in_bin(test_count)       
);



    
    
    
    
endmodule
