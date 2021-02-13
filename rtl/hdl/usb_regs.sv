
module usb_ch_regs (
    
    input clk,
    input reset,
    
    
    input penable,
    input psel,
    input [39:0] paddr,
    input pwrite,
    input [31:0] pwdata,
    output reg [31:0] prdata,
    
    input locked
    
);





localparam USB_REG_LOCKED   = 12'h000;







always @(posedge clk)
begin
    if (reset) begin
    
                   
    end
    else begin
            
        
        if (penable && psel && pwrite) begin
            case ({paddr[11:2], 2'b00})

                                
            endcase
        end
    end
end




always @(posedge clk)
begin
    if (reset) begin
                    
    end
    else begin
                        
        if (penable && psel && !pwrite) begin
            case ({paddr[15:2], 2'b00})
                     
            endcase
        end
    end
end





always @(*)
begin
    prdata = 32'h0;

    case ({paddr[11:2], 2'b00})
        
        USB_REG_LOCKED: prdata = {31'h0, locked};                                        
        
        default: prdata = 32'h0;
    endcase
end






endmodule