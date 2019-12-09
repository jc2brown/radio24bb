`timescale 1ps / 1ps


module tb_ft601_if;

reg reset_n = 1'b0;
reg reset = 1'b1;
wire [31:0] ft_data;
wire [3:0] ft_be;
wire ft_rxf_n;
wire ft_txe_n;
wire ft_rd_n;
wire ft_wr_n;
wire ft_siwu_n;
wire ft_clk;   
wire ft_oe_n;

initial #100000 reset_n = 1'b1;
initial #1000000 reset = 1'b0;




reg clk = 1'b1;
always #4995 begin
    clk <= !clk;
end






ft601 device (    
    .reset_n(reset_n),    
    .data(ft_data),
    .be(ft_be),
    .rxf_n(ft_rxf_n),
    .txe_n(ft_txe_n),
    .rd_n(ft_rd_n),
    .wr_n(ft_wr_n),
    .siwu_n(ft_siwu_n),
    .clk_out(ft_clk),
    .oe_n(ft_oe_n)
);


reg [31:0] wr_data = 32'h00;
reg [3:0] wr_be = 4'b1111;
reg wr_valid = 1'b0;   
wire rd_valid;    
wire [31:0] rd_data;
wire [3:0] rd_be;


    

ft601_if dut (

    .ft601_data(ft_data),
    .ft601_be(ft_be),
    .ft601_rxf_n(ft_rxf_n),
    .ft601_txe_n(ft_txe_n),
    .ft601_rd_n(ft_rd_n),
    .ft601_wr_n(ft_wr_n),
    .ft601_clkin(ft_clk),
    .ft601_oe_n(ft_oe_n),
    
    .clk(clk),
    .reset(reset),
    
    .wr_data(wr_data),
    .wr_be(wr_be),
    .wr_valid(wr_valid),
    .wr_fifo_full(),
    
    .rd_data(rd_data),
    .rd_be(rd_be),
    .rd_en(1'b1),
    .rd_valid(rd_valid),
    .rd_fifo_empty()
        
);



integer j;
always begin
    
                
    if (!reset_n) begin
    
        @(posedge clk) begin
            wr_data <= 32'hX;
            wr_be <= 4'bX;      
            wr_valid <= 1'b0;
        end         
         
        #($urandom_range(110, 110)*1us);
        
    end

    else begin       
    
        
        //#($urandom_range(50, 50)*1us);
        
        wr_data <= 32'h00;
        wr_be <= 4'b1000;     
        wr_valid <= 1'b1;
        
        for (j=0; j<4096; j=j+1) begin
            @(posedge clk) begin
                wr_data <= j+1;          
                wr_be <= {wr_be[2:0], wr_be[3]};           
                wr_valid <= 1'b1;
            end
        end
        @(posedge clk) begin
            wr_data <= 32'hX;
            wr_be <= 4'bX;        
            wr_valid <= 1'b0;   
        end
        
        #($urandom_range(60, 60)*1us);
       // #($urandom_range(50, 50)*1us);
        
    end
end





    
endmodule
