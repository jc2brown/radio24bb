


set adc_clock_outputs [list \
    [get_ports "ADC_CLK_*"] \
]

set_property SLEW FAST $adc_clock_outputs
set_property DRIVE 12 $adc_clock_outputs





set dac_clock_outputs [list \
    [get_ports "DAC_CLKX_*"] \
]

set_property SLEW FAST $dac_clock_outputs
set_property DRIVE 12 $dac_clock_outputs




set dac_outputs [list \
    [get_ports "DAC_DA[*]"] \
    [get_ports "DAC_DB[*]"] \
    [get_ports "DAC_CWN"] \
]

set_property SLEW SLOW $dac_outputs
set_property DRIVE 12 $dac_outputs







set usb_outputs [list \
    [get_ports "USB_D[*]"] \
    [get_ports "USB_BE[*]"] \
    [get_ports "USB_RD_N"] \
    [get_ports "USB_WR_N"] \
]

set_property SLEW SLOW $usb_outputs
set_property DRIVE 12 $usb_outputs






set_property PULLUP true [get_ports CODEC_IO_CLK]
set_property PULLUP true [get_ports CODEC_IO_DATA]
set_property PULLUP true [get_ports USB_IO_CLK]
set_property PULLUP true [get_ports USB_IO_DATA]

set_property PULLUP true [get_ports TCXO_19M2]


