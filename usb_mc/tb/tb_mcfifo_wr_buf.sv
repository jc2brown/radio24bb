`timescale 1ps / 1ps


module tb_mcfifo_wr_buf ();





reg wr_clk = 1;
always #4995 wr_clk <= !wr_clk; 

reg wr_reset = 1;
initial #50000 @(posedge wr_clk) wr_reset <= 0;




reg rd_clk = 1;
always #5005 rd_clk <= !rd_clk; 

reg rd_reset = 1;
initial #50000 @(posedge rd_clk) rd_reset <= 0;





wire [31:0] max_packet_size = 16*4;


reg [35:0] wr_data = 0;
reg wr_en = 0;
reg wr_push = 0;
wire writeable;
wire almost_unwriteable;


wire [35:0] rd_data;
wire rd_valid;
//wire rd_empty;
//wire rd_en = !rd_empty;  
//wire rd_aempty;
//wire readable;


wire [12:0] rd_count;
wire rd_req;





initial begin


    @(negedge wr_reset);
    @(posedge wr_clk);
    
    repeat(100) @(posedge wr_clk);
   
    $display("");    
    $display("writing 1 full packet (%0d words)", max_packet_size/4);
    
    wr_data <= 0;
    repeat(max_packet_size/4) begin
        @(posedge wr_clk) begin
            wr_en <= 1;
            wr_data <= wr_data + 1;
        end
    end

    @(posedge wr_clk) begin
        wr_en <= 0;
        wr_data <= 32'hXXXXXXXX;
    end
    
    
    
    repeat(100) @(posedge wr_clk);
   
    $display("");    
    $display("writing 2 full packets (%0d words)", 2*max_packet_size/4);
    
    wr_data <= 0;
    repeat(2*max_packet_size/4) begin
        @(posedge wr_clk) begin
            wr_en <= 1;
            wr_data <= wr_data + 1;
        end
    end

    @(posedge wr_clk) begin
        wr_en <= 0;
        wr_data <= 32'hXXXXXXXX;
    end
        
        
        
        
    repeat(100) @(posedge wr_clk);
   
    $display("");    
    $display("writing half a packet (%0d words)", max_packet_size/8);
    
    wr_data <= 0;
    repeat(max_packet_size/8) begin
        @(posedge wr_clk) begin
            wr_en <= 1;
            wr_data <= wr_data + 1;
        end
    end
            
    @(posedge wr_clk) begin
        wr_en <= 0;
        wr_push <= 1;
        wr_data <= 32'hXXXXXXXX;
    end

    @(posedge wr_clk) begin
        wr_push <= 0;
        wr_data <= 32'hXXXXXXXX;
    end
        
            
    
    repeat(100) @(posedge wr_clk);
    $finish();
    
    

end





wire rd_xfer_req;
wire rd_xfer_done;


ft601_mcfifo_wr_buf #( .CAPACITY(128) )
dut
(        
    // Depends on number of channels in use: 1:4096, 2:2048, 4:1024
    // Must not be changed while USB tranfers are active
    // Determines behaviour of control signals (readable/writeable) 
    .max_packet_size(max_packet_size), 
        
    .wr_reset(wr_reset),
    .wr_clk(wr_clk),
    .wr_data(wr_data),
    .wr_en(wr_en),
    .wr_push(wr_push),
    
    .rd_reset(rd_reset),
    .rd_clk(rd_clk),
    .rd_data(rd_data),
    .rd_valid(rd_valid),
    .rd_en(rd_xfer_req && !rd_xfer_done),    
    .rd_xfer_done(rd_xfer_done),
    .rd_xfer_almost_done(),
    .rd_xfer_req(rd_xfer_req)
);


endmodule
    