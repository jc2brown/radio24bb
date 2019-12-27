

module regs (
    
    input clk,
    input reset,
    
    
    input penable,
    input psel,
    input [39:0] paddr,
//    input [2:0] pprot,
    input pwrite,
//    input [3:0] pstrb,
    input [31:0] pwdata,
    output reg [31:0] prdata,
//    output pready,
//    output pslverr,
    
    
//    output reg [15:0] ina_gain,    
//    output reg [15:0] ina_offset,  
//    output reg [24:0] ina_filter_cfg_din,
//    output reg ina_filter_cfg_ce,        
        
//    output reg [1:0] ina_stat_cfg,
//    output reg [31:0] ina_stat_limit,
//    input [7:0] ina_stat_min,
//    input [7:0] ina_stat_max,
//    input [31:0] ina_stat_count,    
    
//    output reg [15:0] inb_gain,    
//    output reg [15:0] inb_offset,    
//    output reg [24:0] inb_filter_cfg_din,
//    output reg inb_filter_cfg_ce, 
            
//    output reg [1:0] inb_stat_cfg,
//    output reg [31:0] inb_stat_limit,
//    input [7:0] inb_stat_min,
//    input [7:0] inb_stat_max,
//    input [31:0] inb_stat_count,        
            
//    output reg [15:0] outa_gain,    
//    output reg [15:0] outa_offset,  
//    output reg [24:0] outa_filter_cfg_din,
//    output reg outa_filter_cfg_ce,          
                
//    output reg [15:0] outb_gain,
//    output reg [15:0] outb_offset,
//    output reg [24:0] outb_filter_cfg_din,
//    output reg outb_filter_cfg_ce,        
      
    output reg [1:0] leds,
    
    output reg [31:0] usb_wr_data,
    output reg [3:0] usb_wr_be,
    output reg usb_wr_en,
    input usb_wr_fifo_full,
        
    input [31:0] usb_rd_data,
    input [3:0] usb_rd_be,
    output reg usb_rd_en,
    input usb_rd_fifo_empty,
    
    output reg [1:0] usb_wr_mux,
//    output reg [2:0] outa_mux,
    
    output reg [7:0] dac_cfg,
    output reg dac_cfg_wr_en,
    
    output reg dac_dce,
    
    output reg [1:0] aud_rate,
    
    output reg usb_wr_push,
    
    output reg usb_led_r,
    output reg pwr_led_r
    
//    output reg [31:0] outa_raw,
    
    
    
//    input [15:0] dac_a_wr_count,
//    input [15:0] dac_b_wr_count,
    
//    output reg [7:0] outa_dds_cfg,
//    output reg outa_dds_cfg_ce,
     
//    output reg [31:0] outa_dds_step

    
    
);

//assign pready = 1'b1;
//assign pslverr = 1'b0;


//localparam REG_INA_CFG = 12'h;
//localparam REG_INA_CFG_MASK = 12'h;
//localparam REG_INA_GAIN = 12'h008;
//localparam REG_INA_OFFSET = 12'h00C;
//localparam REG_INA_FILTER_COEF = 12'h010;


//localparam REG_INA_STAT_CFG   = 12'h20;
//localparam REG_INA_STAT_MIN   = 12'h24;
//localparam REG_INA_STAT_MAX   = 12'h28;
//localparam REG_INA_STAT_LIMIT = 12'h2C;
//localparam REG_INA_STAT_COUNT = 12'h30;



//localparam REG_INB_CFG = 12'h400;
//localparam REG_INB_CFG_MASK = 12'h400;
//localparam REG_INB_GAIN = 12'h408;
//localparam REG_INB_OFFSET = 12'h40C;
//localparam REG_INB_FILTER_COEF = 12'h410;


//localparam REG_INB_STAT_CFG   = 12'h420;
//localparam REG_INB_STAT_MIN   = 12'h424;
//localparam REG_INB_STAT_MAX   = 12'h428;
//localparam REG_INB_STAT_LIMIT = 12'h42C;
//localparam REG_INB_STAT_COUNT = 12'h430;


////localparam REG_OUTA_CFG = 12'h800;
////localparam REG_OUTA_CFG_MASK = 12'h800;
//localparam REG_OUTA_GAIN = 12'h808;
////localparam REG_OUTA_OFFSET = 12'h80C;
//localparam REG_OUTA_FILTER_COEF = 12'h810;


////localparam REG_OUTB_CFG = 12'hC00;
////localparam REG_OUTB_CFG_MASK = 12'hC00;
//localparam REG_OUTB_GAIN = 12'hC08;
////localparam REG_OUTB_OFFSET = 12'hC0C;
//localparam REG_OUTB_FILTER_COEF = 12'hC10;


localparam REG_LEDS = 12'h000;


localparam REG_USB_WR_DATA = 12'h004;
localparam REG_USB_WR_FULL = 12'h008; 

localparam REG_USB_RD_DATA = 12'h00C;
localparam REG_USB_RD_EMPTY = 12'h010;


// 0: CPU/regs
// 1: INA
// 2: INB
// 3: USB Loopback
localparam REG_USB_WR_MUX = 12'h014;

// 0: CPU/regs
// 1: INA
// 2: INA FILTERED
// 3: USB
//localparam REG_OUTA_MUX = 12'h1200;


localparam REG_DAC_CFG = 12'h018;
localparam REG_DAC_DCE = 12'h01C;


localparam REG_AUD_RATE = 12'h020;

localparam REG_USB_WR_PUSH = 12'h024;

localparam REG_USB_LED_R = 12'h028;
localparam REG_PWR_LED_R = 12'h02C;

//localparam REG_OUTA_RAW = 12'h1400;

//localparam REG_OUTA_WR_COUNT = 12'h1500;
//localparam REG_OUTB_WR_COUNT = 12'h1504;


//localparam REG_OUTA_DDS_CFG = 12'h1600;
//localparam REG_OUTA_DDS_STEP = 12'h1604;


/*
localparam REG_INA_CFG = 12'h;
localparam REG_INA_CFG_MASK = 12'h;

localparam REG_INA_MULT = 12'h10;
localparam REG_INA_LOG2_DIV = 12'h10;

localparam REG_INA_STAT_CFG = 12'h30;
localparam REG_INA_STAT_MIN = 12'h30;
localparam REG_INA_STAT_MAX = 12'h30;
localparam REG_INA_STAT_SUM = 12'h30;
localparam REG_INA_STAT_COUNT = 12'h30;
localparam REG_INA_STAT_LIMIT = 12'h30;

*/


always @(posedge clk)
begin
    if (reset) begin
        
//        ina_gain <= 'h0;
//        ina_offset <= 'h0;
//        ina_filter_cfg_din <= 'h0;
//        ina_filter_cfg_ce <= 'h0;
        
//        ina_stat_cfg <= 'h1;
//        ina_stat_limit <= 'h0;
                    
//        inb_gain <= 'h0;
//        inb_offset <= 'h0;
//        inb_filter_cfg_din <= 'h0;
//        inb_filter_cfg_ce <= 'h0;
        
//        inb_stat_cfg <= 'h1;
//        inb_stat_limit <= 'h0;
                    
//        outb_gain <= 'h0;
//        outb_offset <= 'h0;
//        outa_filter_cfg_din <= 'h0;
//        outa_filter_cfg_ce <= 'h0;
                    
//        outb_gain <= 'h0;
//        outb_offset <= 'h0;
//        outb_filter_cfg_din <= 'h0;
//        outb_filter_cfg_ce <= 'h0;
        
        leds <= 2'b00;
        
        usb_wr_data <= 32'h0;
        usb_wr_be <= 4'h0;
        usb_wr_en <= 1'b0;
        
        dac_cfg <= 8'h0;
        dac_cfg_wr_en <= 1'b0;
        
        dac_dce <= 1'b0;
        
        aud_rate <= 2'b0;
        
        usb_wr_push <= 1'b0;
        
        usb_led_r <= 1'b0;
        pwr_led_r <= 1'b0;
        
//        outa_raw <= 'h0;       
//        outa_mux <= 'h0; 
        
//        outa_dds_cfg <= 'h0;
//        outa_dds_cfg_ce <= 1'b0;
//        outa_dds_step <= 'h0;
                   
    end
    else begin
                
//        ina_filter_cfg_ce <= 'h0;
//        inb_filter_cfg_ce <= 'h0;
//        outa_filter_cfg_ce <= 'h0;
//        outb_filter_cfg_ce <= 'h0;
        
        usb_wr_en <= 1'b0;    
        usb_wr_push <= 1'b0;    
        dac_cfg_wr_en <= 1'b0;
        
//        outa_dds_cfg_ce <= 1'b0;
                                
        
        if (penable && psel && pwrite) begin
            case ({paddr[11:2], 2'b00})
                        
//                REG_INA_GAIN: ina_gain <= pwdata[15:0];
                
//                REG_INA_OFFSET: ina_offset <= pwdata[15:0];
                
//                REG_INA_FILTER_COEF:
//                    begin
//                        ina_filter_cfg_din <= pwdata[24:0];
//                        ina_filter_cfg_ce <= 1'b1;
//                    end
                               
//                REG_INA_STAT_CFG: ina_stat_cfg <= pwdata[1:0];
                
//                REG_INA_STAT_LIMIT: ina_stat_limit <= pwdata;
                
//                REG_INB_GAIN: inb_gain <= pwdata[15:0];  
                
//                REG_INB_OFFSET: inb_offset <= pwdata[15:0];  
                
//                REG_INB_FILTER_COEF:
//                    begin
//                        inb_filter_cfg_din <= pwdata[24:0];
//                        inb_filter_cfg_ce <= 1'b1;
//                    end                          
                               
//                REG_INB_STAT_CFG: inb_stat_cfg <= pwdata[1:0];
                
//                REG_INB_STAT_LIMIT: inb_stat_limit <= pwdata;                  
               
//                REG_OUTA_GAIN: outa_gain <= pwdata[15:0];     
                  
//                REG_OUTA_FILTER_COEF:
//                    begin
//                        outa_filter_cfg_din <= pwdata[24:0];
//                        outa_filter_cfg_ce <= 1'b1;
//                    end                        
                 
//                REG_OUTB_GAIN: outb_gain <= pwdata[15:0];  
                                                                
//                REG_OUTB_FILTER_COEF:
//                    begin
//                        outb_filter_cfg_din <= pwdata[24:0];
//                        outb_filter_cfg_ce <= 1'b1;
//                    end
                
                REG_LEDS: leds <= pwdata[1:0];   

                REG_USB_WR_DATA: 
                    begin
                        usb_wr_data <= pwdata;
                        usb_wr_be <= 4'hF;
                        usb_wr_en <= 1'b1;
                    end
                    
                REG_USB_WR_MUX: usb_wr_mux <= pwdata[1:0];   
                                    
                    
                REG_DAC_CFG:
                    begin
                        dac_cfg <= pwdata[7:0];
                        dac_cfg_wr_en <= 1'b1;
                    end
                                       
                REG_DAC_DCE: dac_dce <= pwdata[0];
                
                REG_AUD_RATE: aud_rate <= pwdata[0];
                
                REG_USB_WR_PUSH: usb_wr_push <= pwdata[0];
                
                REG_USB_LED_R: usb_led_r <= pwdata[0];
                
                REG_PWR_LED_R: pwr_led_r <= pwdata[0];
                
//                REG_OUTA_RAW: outa_raw <= pwdata;   
               
//                REG_OUTA_MUX: outa_mux <= pwdata[2:0];   
                
//                REG_OUTA_DDS_CFG: 
//                    begin
//                        outa_dds_cfg <= pwdata[7:0];
//                        outa_dds_cfg_ce <= 1'b1;
//                    end
               
//                REG_OUTA_DDS_STEP: outa_dds_step <= pwdata;   
                
            endcase
        end
    end
end




always @(posedge clk)
begin
    if (reset) begin
        usb_rd_en <= 1'b0;                   
    end
    else begin
                
        usb_rd_en <= 1'b0;       
            
        if (penable && psel && !pwrite) begin
            case ({paddr[15:2], 2'b00})
            
                REG_USB_RD_DATA: usb_rd_en <= 1'b1;           
                     
            endcase
        end
    end
end





always @(*)
begin
    prdata = 32'h0;

    case ({paddr[11:2], 2'b00})
               
//        REG_INA_GAIN: prdata = ina_gain;
        
//        REG_INA_STAT_MIN: prdata = ina_stat_min;
        
//        REG_INA_STAT_MAX: prdata = ina_stat_max;
        
//        REG_INA_STAT_COUNT: prdata = ina_stat_count;
                
//        REG_INB_STAT_MIN: prdata = inb_stat_min;
        
//        REG_INB_STAT_MAX: prdata = inb_stat_max;
        
//        REG_INB_STAT_COUNT: prdata = inb_stat_count;
        
        REG_LEDS: prdata = leds;
        
        REG_USB_WR_FULL: prdata = {31'h0, usb_wr_fifo_full};
        
        REG_USB_RD_DATA: 
            begin
                prdata = usb_rd_data;
            end
        
        REG_USB_RD_EMPTY: prdata = {31'h0, usb_rd_fifo_empty};
        
//        REG_OUTA_WR_COUNT: prdata = dac_a_wr_count;
        
//        REG_OUTB_WR_COUNT: prdata = dac_b_wr_count;
        
                                
        
        default: prdata = 32'h0;
    endcase
end





endmodule
