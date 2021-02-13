

module usb_ch_regs (
    
    input clk,
    input reset,
    
    
    input penable,
    input psel,
    input [39:0] paddr,
    input pwrite,
    input [31:0] pwdata,
    output reg [31:0] prdata,
    
    
    
    output reg [3:0]    wr_mux,
    output reg [31:0]   wr_data,
    output reg [3:0]    wr_be,
    output reg          wr_en,
    output reg          wr_push,
    input wire          wr_full,    

    output reg [31:0]   wr_auto_trigger_period,


    output reg [3:0]    rd_mux,
    input reg [31:0]    rd_data,
    input reg [3:0]     rd_be,
    input reg           rd_en,
    input wire          rd_empty
    
      
    
    
    
);





localparam USB_REG_WR_MUX   = 12'h000;
localparam USB_REG_WR_DATA  = 12'h004;
localparam USB_REG_WR_EN    = 12'h008;
localparam USB_REG_WR_PUSH  = 12'h00C;
localparam USB_REG_WR_FULL  = 12'h010;
localparam USB_REG_WR_ATRIG = 12'h014;



localparam USB_REG_RD_MUX   = 12'h020;
localparam USB_REG_RD_DATA  = 12'h024;
localparam USB_REG_RD_EN    = 12'h028;
localparam USB_REG_RD_EMPTY = 12'h02C;







always @(posedge clk)
begin
    if (reset) begin
    
        wr_mux <= '0;
        wr_data <= '0;
        wr_be <= '0;
        wr_en <= '0;
        wr_push <= '0;
        wr_auto_trigger_period <= '0;
        
                   
    end
    else begin
            
        wr_en <= 1'b0;    
        wr_push <= 1'b0;   
        
        
        if (penable && psel && pwrite) begin
            case ({paddr[11:2], 2'b00})


                USB_REG_WR_MUX: wr_mux <= pwdata[3:0];                   
                                                        
                USB_REG_WR_DATA: 
                    begin
                        wr_data <= pwdata;
                        wr_be <= 4'hF;
                        wr_en <= 1'b1;
                    end                    
                                                                     
                USB_REG_WR_PUSH: wr_push <= 1'b1;
                
                USB_REG_WR_ATRIG: wr_auto_trigger_period <= pwdata[31:0];

                                
            endcase
        end
    end
end




always @(posedge clk)
begin
    if (reset) begin
        rd_data <= 1'b0;                   
    end
    else begin
                
        rd_en <= 1'b0;       
            
        if (penable && psel && !pwrite) begin
            case ({paddr[15:2], 2'b00})
            
                USB_REG_RD_DATA: rd_en <= 1'b1;
                     
            endcase
        end
    end
end





always @(*)
begin
    prdata = 32'h0;

    case ({paddr[11:2], 2'b00})
        
        USB_REG_WR_FULL: prdata = {31'h0, wr_full};
        
        USB_REG_RD_DATA: 
            begin
                prdata = rd_data;
            end
        
        USB_REG_RD_EMPTY: prdata = {31'h0, rd_empty};
                                        
        
        default: prdata = 32'h0;
    endcase
end





endmodule
