

create_clock -name TCXO_19M2 -period 52.083 [get_ports TCXO_19M2];
create_clock -name ADC_DCLKA -period 10.000 [get_ports ADC_DCLKA];
create_clock -name ADC_DCLKB -period 10.000 [get_ports ADC_DCLKB];
create_clock -name USB_CLK -period 10.000 [get_ports USB_CLK];


#create_clock -name pl_clk0 -period 10.000 [get_pins r24bb_bd_inst/processing_system7_0/inst/buffer_fclk_clk_0.FCLK_CLK_0_BUFG/O]


# Create an alias to FCLK_CLK_0 as pl_clk0
#create_generated_clock   -name pl_clk0   [get_pins r24bb_bd_inst/pl_clk0]

# Create an alias to FCLK_CLK_0 as mclk
create_generated_clock   -name mclk   [get_pins MMCME2_BASE_inst/CLKOUT0]





 
set_clock_groups -asynchronous \
    -group {mclk} \
    -group {clk_fpga_0} \
    -group {TCXO_19M2} \
    -group {ADC_DCLKA} \
    -group {ADC_DCLKB} \
    -group {USB_CLK} \
