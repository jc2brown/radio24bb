

module mpx_regs (
    
    input clk,
    input reset,
    

${port_decls}


        
    input penable,
    input psel,
    input [31:0] paddr,
    input pwrite,
    input [31:0] pwdata,
    output reg [31:0] prdata  
        
);




${regs}
              

        
${slv_rd_assns}    




endmodule

