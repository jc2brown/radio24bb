

module ft601_data_sink
#(
    parameter MAX_PACKET_SIZE = 1024,
    parameter CHANNEL_NUM = 0
)
(    
    
    input reset,
    input clk,    
    
    input  [31:0] pc_rx_data,
    input  [3:0] pc_rx_be,
    output  pc_rx_rd_en,
    input  pc_rx_valid,
    
    input pc_rx_empty

);
    


localparam BYTES_PER_WORD = 4;

reg [31:0] word_count;
reg [31:0] wait_cycles_remaining;
reg [31:0] blob_bytes_remaining;
reg [31:0] packet_bytes_remaining;


reg is_first_word;
reg [31:0] last_word;
reg [3:0] last_be;


assign pc_rx_rd_en = pc_rx_valid; 

always @(posedge clk) begin
    if (reset) begin
        is_first_word <= 1;
        last_word <= 0;
    end    
    else begin
//        pc_rx_rd_en <= pc_rx_valid;
        if (pc_rx_valid) begin
            last_word <= pc_rx_data;
            last_be <= pc_rx_be;
            if (is_first_word) begin
                is_first_word <= 0;                
            end
            else begin
                if (pc_rx_data != last_word + 1) begin
                    $display("ERROR: ft601_data_sink: non-consecutive data @ channel %0d: 0x%08X -> 0x%08X", CHANNEL_NUM, pc_rx_data, last_word);
                    $finish();
                end
                if (pc_rx_be != {last_be[2:0], last_be[3]}) begin
                    $display("ERROR: ft601_data_sink: non-consecutive BE @ channel %0d: 0x%04X -> 0x%04X", CHANNEL_NUM, pc_rx_be, last_be);
                    $finish();
                end
                if (pc_rx_data[31:28] != CHANNEL_NUM) begin
                    $display("ERROR: ft601_data_sink: channel %0d received data meant for channel %0d", CHANNEL_NUM, pc_rx_data[31:28]);
                    $finish();
                end
            end
        end
    end
end
/*

// USB data source
always @(posedge clk) begin

    if (reset) begin
//        pc_rx_rd_en <= 1'b0;       
        word_count <= 0;
        wait_cycles_remaining <= $urandom_range(1000, 5000);      
        blob_bytes_remaining <= 20000;
        packet_bytes_remaining <= 0;
    end         
    
    else begin
    
//        pc_rx_rd_en <= 1'b0;        
    
        if (wait_cycles_remaining > 0) begin        
            wait_cycles_remaining <= wait_cycles_remaining - 1;        
        end
    
        else if (packet_bytes_remaining > 0) begin
        
            if (pc_rx_empty) begin
//                pc_rx_rd_en <= 1'b0;  
            end 
            else begin
        
//                pc_rx_rd_en <= 1'b1;  
                word_count <= word_count + 1;
                
                blob_bytes_remaining <= blob_bytes_remaining - BYTES_PER_WORD;
                packet_bytes_remaining <= packet_bytes_remaining - BYTES_PER_WORD;
                
            end
        end
        else if (blob_bytes_remaining >= MAX_PACKET_SIZE) begin
//                        pc_rx_rd_en <= 1'b0;  
            wait_cycles_remaining <= (8*MAX_PACKET_SIZE)/BYTES_PER_WORD; // Wait long enough for every other channel to tranfer a packet
            packet_bytes_remaining <= MAX_PACKET_SIZE;            
        end
        else if (blob_bytes_remaining > 0) begin
//                        pc_rx_rd_en <= 1'b0;  
            wait_cycles_remaining <= (8*MAX_PACKET_SIZE)/BYTES_PER_WORD; // Wait long enough for every other channel to tranfer a packet
            packet_bytes_remaining <= blob_bytes_remaining;            
        end
        else begin
        
        end

                    
    end
end


    */
    
endmodule
