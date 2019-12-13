
task apb_write (
    input [31:0] addr, 
    input [31:0] data
);

    // T1
    @(posedge clk) begin
        paddr <= addr;
        pwrite <= 1;
        psel <= 1;
        pwdata <= data;
    end
    
    // T2
    @(posedge clk) begin
        penable <= 1;
    end
    
    // T3
    @(posedge clk) begin
        if (pready) begin
            psel <= 0;
            penable <= 0;
            pwrite <= 0;
            pwdata <= 0;
            paddr <= 0;
        end
    end

endtask    
    
    
    
    
    
    
    
     
task apb_read (
    input [31:0] addr, 
    output [31:0] data
);

    // T1
    @(posedge clk) begin
        paddr <= addr;
        pwrite <= 0;
        psel <= 1;
    end
    
    // T2
    @(posedge clk) begin
        penable <= 1;
    end
    
    // T3
    @(posedge clk) begin
        if (pready) begin
            psel <= 0;
            penable <= 0;
            data <= prdata;
            paddr <= 0;
        end
    end

endtask    
    
      