`timescale 1ps / 1ps


module tb_dac_widthconv(

    );

/*
reg clk = 1;
always #5000 clk <= !clk;

reg reset = 1;
initial #50000 reset <= 0;

reg [3:0] dac_cw = 1;
reg [31:0] dac_a_data = 32'h03020100;
always @(posedge clk) dac_a_data <= dac_a_data + 32'h04040404;
wire dac_a_full;
wire dac_a_wr_en = !dac_a_full;


wire [31:0] dia_fifo_o;
wire [7:0] dib_fifo_o;
wire [3:0] cw_fifo;

//wire [7:0] dia_fifo = dia_fifo_o + 128;
wire [7:0] dib_fifo = dib_fifo_o + 128;


reg [2:0] bytes_avail = 0;
reg [31:0] dia_fifo_buffer;
reg [3:0] cw_fifo_buffer;
reg [7:0] dia;
reg cw;
reg rd_en;

xpm_fifo_async #(
    .CDC_SYNC_STAGES(2),       // DECIMAL
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(1024),   // DECIMAL
    .READ_DATA_WIDTH(36),      // DECIMAL
    .WRITE_DATA_WIDTH(36)     // DECIMAL
)
dac_a_fifo_inst (

    .rst(reset),   
    
    .wr_clk(clk),
    .din({dac_cw, dac_a_data}),      
    .wr_en(dac_a_wr_en),    
    .full(dac_a_full),
    
    .rd_clk(clk),
    .dout({cw_fifo, dia_fifo_o}),  
    .rd_en(rd_en)
);



always @(posedge clk) begin
    if (reset) begin
        bytes_avail <= 0;
        rd_en <= 1'b0;
        dia_fifo_buffer <= 0;
        cw_fifo_buffer <= 0;
        dia <= 0;
        cw <= 0;
    end
    else begin
    
        rd_en <= 1'b0;
        
        if (bytes_avail == 0) begin
            rd_en <= 1'b1;
            bytes_avail <= 4;
        end 
        if (bytes_avail == 4) begin
            dia_fifo_buffer <= dia_fifo_o;    
            cw_fifo_buffer <= cw_fifo;        
            dia <= dia_fifo_o[7:0] + 128;
            cw <= cw_fifo[0];
            bytes_avail <= 3;
        end 
        if (bytes_avail == 3) begin
            dia <= dia_fifo_buffer[15:8] + 128;
            bytes_avail <= 2;
        end 
        if (bytes_avail == 2) begin
            dia <= dia_fifo_buffer[23:16] + 128;
            bytes_avail <= 1;
        end 
        if (bytes_avail == 1) begin
            dia <= dia_fifo_buffer[31:24] + 128;
            rd_en <= 1'b1;
            bytes_avail <= 4;
        end 
    end
end

*/

   
   
   
   
reg clk = 1;
always #5000 clk <= !clk;

reg reset = 1;
initial #50000 reset <= 0;

reg [3:0] dac_cw = 1;
reg [31:0] dac_a_data = 32'h03020100;
always @(posedge clk) dac_a_data <= dac_a_data + 32'h04040404;
wire dac_a_full;
wire dac_a_wr_en = !dac_a_full;


wire [7:0] dia_fifo_o;
wire [7:0] dib_fifo_o;
wire [3:0] cw_fifo;

//wire [7:0] dia_fifo = dia_fifo_o + 128;
wire [7:0] dib_fifo = dib_fifo_o + 128;

/*
reg [2:0] bytes_avail = 0;
reg [31:0] dia_fifo_buffer;
reg [3:0] cw_fifo_buffer;
reg [7:0] dia;
reg cw;
reg rd_en;
*/
xpm_fifo_async #(
    .CDC_SYNC_STAGES(2),       // DECIMAL
    .DOUT_RESET_VALUE("0"),    // String
    .FIFO_MEMORY_TYPE("block"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(1024),   // DECIMAL
    .READ_DATA_WIDTH(9),      // DECIMAL
    .WRITE_DATA_WIDTH(36)     // DECIMAL
)
dac_a_fifo_inst (

    .rst(reset),   
    
    .wr_clk(clk),
    .din({
        dac_cw[3], dac_a_data[31:24],
        dac_cw[2], dac_a_data[23:16],
        dac_cw[1], dac_a_data[15:8],
        dac_cw[0], dac_a_data[7:0]
    }),      
    .wr_en(dac_a_wr_en),    
    .full(dac_a_full),
    
    .rd_clk(clk),
    .dout({cw_fifo, dia_fifo_o}),  
    .rd_en(1)
);

/*

always @(posedge clk) begin
    if (reset) begin
        bytes_avail <= 0;
        rd_en <= 1'b0;
        dia_fifo_buffer <= 0;
        cw_fifo_buffer <= 0;
        dia <= 0;
        cw <= 0;
    end
    else begin
    
        rd_en <= 1'b0;
        
        if (bytes_avail == 0) begin
            rd_en <= 1'b1;
            bytes_avail <= 4;
        end 
        if (bytes_avail == 4) begin
            dia_fifo_buffer <= dia_fifo_o;    
            cw_fifo_buffer <= cw_fifo;        
            dia <= dia_fifo_o[7:0] + 128;
            cw <= cw_fifo[0];
            bytes_avail <= 3;
        end 
        if (bytes_avail == 3) begin
            dia <= dia_fifo_buffer[15:8] + 128;
            bytes_avail <= 2;
        end 
        if (bytes_avail == 2) begin
            dia <= dia_fifo_buffer[23:16] + 128;
            bytes_avail <= 1;
        end 
        if (bytes_avail == 1) begin
            dia <= dia_fifo_buffer[31:24] + 128;
            rd_en <= 1'b1;
            bytes_avail <= 4;
        end 
    end
end

*/






endmodule
