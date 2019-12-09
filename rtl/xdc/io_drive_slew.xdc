
set_property SLEW FAST [get_ports "ADC_CLK_P"];
set_property SLEW FAST [get_ports "ADC_CLK_N"];

set_property DRIVE 16 [get_ports "ADC_CLK_P"];
set_property DRIVE 16 [get_ports "ADC_CLK_N"];


set_property SLEW FAST [get_ports "DAC_CLKX_P"];
set_property SLEW FAST [get_ports "DAC_CLKX_N"];

set_property DRIVE 16 [get_ports "DAC_CLKX_P"];
set_property DRIVE 16 [get_ports "DAC_CLKX_N"];


