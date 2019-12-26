`timescale 1ps / 1ps


module tb_ft601_if2;

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
//always #5005 begin
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
reg wr_push = 0;
wire wr_full;
    

ft601_if2 dut (

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
    .wr_push(wr_push),
    .wr_full(wr_full),
    
    .rd_data(rd_data),
    .rd_be(rd_be),
    .rd_en(1'b0),
    .rd_valid(rd_valid)
        
);


reg _wr_valid;
always @(*) wr_valid <= _wr_valid && !wr_full; //? 0 : (_wr_valid : 0; 


integer j;
always begin
    
                
    if (!reset_n) begin
    
        @(posedge clk) begin
            wr_data <= 32'hX;
            wr_be <= 4'bX;      
            _wr_valid <= 1'b0;
        end         
         
        #($urandom_range(10000, 10000)*1us);
        
    end

    else begin       
    
        
        //#($urandom_range(50, 50)*1us);
        
        wr_data <= 32'h00;
        wr_be <= 4'b1000;     
        _wr_valid <= 1'b0;
        
        for (j=0; j<8192; ) begin
            @(posedge clk) begin
            /*
                _wr_valid <= 1;            
                if (wr_valid && !wr_full) begin
                    wr_data <= j;          
                    wr_be <= {wr_be[2:0], wr_be[3]};           
                    //_wr_valid <= 1'b1;
                    j=j+1;
                end
                */
                
                     
                _wr_valid <= 1;//!wr_full;
                if (!wr_full) begin
                    wr_data <= j;          
                    wr_be <= {wr_be[2:0], wr_be[3]};     
                    j=j+1;
                end
                
                
                
            end
        end
        @(posedge clk) begin
            j = 0;
            wr_data <= 32'hX;
            wr_be <= 4'bX;        
            _wr_valid <= 1'b0;   
            wr_valid <= 0;
        end
        
        #($urandom_range(400, 400)*1us);
       // #($urandom_range(50, 50)*1us);
       
       
       
       
               
       wr_data <= 32'h00;
       wr_be <= 4'b1000;     
       _wr_valid <= 1'b0;
       
       for (j=0; j<1024; ) begin
           @(posedge clk) begin
           
//               _wr_valid <= 1;           
//               if (wr_valid && !wr_full) begin
               
               
               
               _wr_valid <= 1;//!wr_full;
               if (!wr_full) begin
                   wr_data <= j;          
                   wr_be <= {wr_be[2:0], wr_be[3]};           
                   //_wr_valid <= 1'b1;
                   j=j+1;
               end
           end
       end
       @(posedge clk) begin
           wr_data <= 32'hX;
           wr_be <= 4'bX;        
           _wr_valid <= 1'b0;   
           wr_push <= 1;
       end
      @(posedge clk) begin
          wr_push <= 0;
      end
       
       #($urandom_range(400, 400)*1us);
      // #($urandom_range(50, 50)*1us);
      
      
      
      
       
       
       
       
       
       
       
        
    end
end



    
    




    
endmodule
