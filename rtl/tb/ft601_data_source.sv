

module ft601_data_source #(
    parameter MAX_PACKET_SIZE = 1024,
    parameter CHANNEL_NUM = 0
)
(    
    
    input reset,
    input clk,
    
    output reg [31:0] pc_tx_data,
    output reg [3:0] pc_tx_be,
    output reg pc_tx_en,
    output reg pc_tx_push,
        
    input pc_tx_full

);


localparam BYTES_PER_WORD = 4;

reg [31:0] word_count;
reg [31:0] wait_cycles_remaining;
reg [31:0] blob_bytes_remaining;
reg [31:0] packet_bytes_remaining;

reg need_push;

integer k;


// USB data source
always @(posedge clk) begin

    if (reset) begin
        pc_tx_data <= 32'hX;
        pc_tx_be <= 4'hX;
        pc_tx_en <= 1'b0;       
        pc_tx_push <= 1'b0; 
        word_count <= 32'h10000000 * CHANNEL_NUM;
        need_push <= 1;
        wait_cycles_remaining <= $urandom_range(1000, 5000);      
        blob_bytes_remaining <= 20000;
        packet_bytes_remaining <= 0;
    end         
    
    else begin
    
        pc_tx_data <= 32'hX;
        pc_tx_en <= 1'b0;        
        pc_tx_be <= 4'h8;
    
        if (wait_cycles_remaining > 0) begin        
            wait_cycles_remaining <= wait_cycles_remaining - 1;        
        end
    
        else if (packet_bytes_remaining > 0) begin
        
            if (pc_tx_full) begin
                pc_tx_en <= 1'b0;  
            end 
            else begin
        
                pc_tx_en <= 1'b1;  
                pc_tx_data <= word_count; 
                word_count <= word_count + 1;
//                pc_tx_be <= 4'hF;
                pc_tx_be <= {pc_tx_be[2:0], pc_tx_be[3]};
                
                blob_bytes_remaining <= blob_bytes_remaining - BYTES_PER_WORD;
                packet_bytes_remaining <= packet_bytes_remaining - BYTES_PER_WORD;
                
            end
        end
        else if (blob_bytes_remaining >= MAX_PACKET_SIZE) begin
//            wait_cycles_remaining <= (7*MAX_PACKET_SIZE)/BYTES_PER_WORD; // Wait long enough for every other channel to tranfer a packet
            packet_bytes_remaining <= MAX_PACKET_SIZE;            
        end
        else if (blob_bytes_remaining > 0) begin
//            wait_cycles_remaining <= (7*MAX_PACKET_SIZE)/BYTES_PER_WORD; // Wait long enough for every other channel to tranfer a packet
            packet_bytes_remaining <= blob_bytes_remaining;            
        end
        else if (need_push) begin
            need_push <= 0;
            pc_tx_push <= 1'b1;     
        end
        else begin
            pc_tx_push <= 1'b0;
        end

                    
    end
end




endmodule
