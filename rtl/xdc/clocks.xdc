

create_clock -name TCXO_19M2 -period 52.083 [get_ports TCXO_19M2];
create_clock -name ADC_DCLKA -period 10.000 [get_ports ADC_DCLKA];
create_clock -name ADC_DCLKB -period 10.000 [get_ports ADC_DCLKB];
create_clock -name USB_CLK -period 10.000 [get_ports USB_CLK];


set mclk  [get_clocks -of_objects [get_pins mclk_mmcm/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == clk_mmcm_clkout}]


set_clock_groups -asynchronous \
    -group {clk_fpga_0 clk_mmcm_clkout} \
    -group {mclk_mmcm_clkout} \
    -group {TCXO_19M2} \
    -group {ADC_DCLKA} \
    -group {ADC_DCLKB} \
    -group {USB_CLK}


#set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks -of_objects [get_pins mclk_mmcm/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == clk_fpga_0}]


set_clock_groups -asynchronous \
    -group {clk_fpga_0 clk_mmcm_clkout} \
    -group [list $mclk mclk_mmcm_clkout] \
    -group {TCXO_19M2} \
    -group {ADC_DCLKA} \
    -group {ADC_DCLKB} \
    -group {USB_CLK}
