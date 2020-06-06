
set_property SLEW FAST [get_ports ADC_CLK_P]
set_property SLEW FAST [get_ports ADC_CLK_N]

set_property DRIVE 16 [get_ports ADC_CLK_P]
set_property DRIVE 16 [get_ports ADC_CLK_N]






set_property SLEW FAST [get_ports DAC_CLKX_P]
set_property SLEW FAST [get_ports DAC_CLKX_N]

set_property DRIVE 16 [get_ports DAC_CLKX_P]
set_property DRIVE 16 [get_ports DAC_CLKX_N]




set_property PULLUP true [get_ports CODEC_IO_CLK]
set_property PULLUP true [get_ports CODEC_IO_DATA]
set_property PULLUP true [get_ports USB_IO_CLK]
set_property PULLUP true [get_ports USB_IO_DATA]

set_property PULLUP true [get_ports TCXO_19M2]


