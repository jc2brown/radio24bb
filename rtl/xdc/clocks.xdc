

create_clock -period 52.083 -name TCXO_19M2 [get_ports TCXO_19M2]
create_clock -period 10.000 -name ADC_DCLKA [get_ports ADC_DCLKA]
create_clock -period 10.000 -name ADC_DCLKB [get_ports ADC_DCLKB]
create_clock -period 10.000 -name USB_CLK [get_ports USB_CLK]


#create_clock -name pl_clk0 -period 10.000 [get_pins r24bb_bd_inst/processing_system7_0/inst/buffer_fclk_clk_0.FCLK_CLK_0_BUFG/O]


# Create an alias to FCLK_CLK_0 as pl_clk0
#create_generated_clock   -name pl_clk0   [get_pins r24bb_bd_inst/pl_clk0]

# Create an alias to FCLK_CLK_0 as mclk
#create_generated_clock   -name mclk   [get_pins MMCME2_BASE_inst/CLKOUT0]



#set_clock_groups -asynchronous #    -group [get_clocks -of_objects [get_pins r24bb_bd_inst/clk_clkwiz/inst/CLK_CORE_DRP_I/clk_inst/mmcm_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == tcxo_96m_pll_clkout0}] #    -group [get_clocks -of_objects [get_pins r24bb_bd_inst/clk_clkwiz/inst/CLK_CORE_DRP_I/clk_inst/mmcm_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == clk_fpga_0}]

#set_clock_groups -asynchronous #    -group [get_clocks -of_objects [get_pins r24bb_bd_inst/mclk_clkwiz/inst/CLK_CORE_DRP_I/clk_inst/mmcm_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == tcxo_96m_pll_clkout0}] #    -group [get_clocks -of_objects [get_pins r24bb_bd_inst/mclk_clkwiz/inst/CLK_CORE_DRP_I/clk_inst/mmcm_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == clk_fpga_0}]


set_clock_groups -asynchronous -group TCXO_19M2 -group clk_fpga_0 -group clk0_mmcm -group [get_clocks -of_objects [get_pins MMCME2_BASE_inst/CLKOUT0]] -group ADC_DCLKA -group ADC_DCLKB -group USB_CLK
#        -group [get_clocks -of_objects [get_pins r24bb_bd_inst/clk_clkwiz/inst/CLK_CORE_DRP_I/clk_inst/mmcm_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == tcxo_96m_pll_clkout0}] #        -group [get_clocks -of_objects [get_pins r24bb_bd_inst/clk_clkwiz/inst/CLK_CORE_DRP_I/clk_inst/mmcm_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == clk_fpga_0}] #        -group [get_clocks -of_objects [get_pins r24bb_bd_inst/mclk_clkwiz/inst/CLK_CORE_DRP_I/clk_inst/mmcm_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == tcxo_96m_pll_clkout0}] #        -group [get_clocks -of_objects [get_pins r24bb_bd_inst/mclk_clkwiz/inst/CLK_CORE_DRP_I/clk_inst/mmcm_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == clk_fpga_0}] #        -group {TCXO_19M2} #    -group {mclk} #    -group {clk_fpga_0}




set timed_usb_bidirs [list \
    [get_ports "USB_D[*]"] \
    [get_ports "USB_BE[*]"] \
]

set timed_usb_inputs [list \
    [get_ports "USB_TXE_N"] \
    [get_ports "USB_RXF_N"] \
    $timed_usb_bidirs \
]

set timed_usb_outputs [list \
    [get_ports "USB_RD_N"] \
    [get_ports "USB_WR_N"] \
    $timed_usb_bidirs \
]



# ORIGINAL ATTEMPT
#set_input_delay -clock [get_clocks USB_CLK] -min -add_delay 2.700 $timed_usb_inputs
#set_input_delay -clock [get_clocks USB_CLK] -max -add_delay 3.800 $timed_usb_inputs

#set_output_delay -clock [get_clocks USB_CLK] -min -add_delay -5.100 $timed_usb_outputs
#set_output_delay -clock [get_clocks USB_CLK] -max -add_delay 1.300 $timed_usb_outputs



# FROM FTDI REFERENCE DESIGN
#set_input_delay -clock [get_clocks fifoClk] -max 7    [get_ports {RXF_N}]
#set_input_delay -clock [get_clocks fifoClk] -min 6.5  [get_ports {RXF_N}]

#set_input_delay -clock [get_clocks fifoClk] -max 7    [get_ports {BE[*] DATA[*]}]
#set_input_delay -clock [get_clocks fifoClk] -min 6.5  [get_ports {BE[*] DATA[*]}]

#set_output_delay -clock [get_clocks fifoClk] -max 1.0 [get_ports {WR_N RD_N OE_N}]
#set_output_delay -clock [get_clocks fifoClk] -min 4.8 [get_ports {WR_N RD_N OE_N}]

#set_output_delay -clock [get_clocks fifoClk] -max 1.0 [get_ports {BE[*] DATA[*]}]
#set_output_delay -clock [get_clocks fifoClk] -min 4.8 [get_ports {BE[*] DATA[*]}]



# USING REFERENCE VALUES
#set_input_delay -clock [get_clocks USB_CLK] -min -add_delay 6.5 $timed_usb_inputs
#set_input_delay -clock [get_clocks USB_CLK] -max -add_delay 7.0 $timed_usb_inputs

#set_output_delay -clock [get_clocks USB_CLK] -min -add_delay 4.8 $timed_usb_outputs
#set_output_delay -clock [get_clocks USB_CLK] -max -add_delay 1.0 $timed_usb_outputs










#############################################################
#
# SECOND ATTEMPT    
#
#############################################################


set interconnect_length_mm 6

set fpga_to_jx1_min_trace_length_mm 43
set fpga_to_jx1_max_trace_length_mm 65

set fpga_to_jx2_min_trace_length_mm 41
set fpga_to_jx2_max_trace_length_mm 54


set jx1_to_usb_min_trace_length_mm 11
set jx1_to_usb_min_trace_length_mm 27

set jx2_to_dac_min_trace_length_mm 31
set jx2_to_dac_min_trace_length_mm 54

set jx2_to_adc_min_trace_length_mm 21
set jx2_to_adc_min_trace_length_mm 40



set fpga_to_usb_min_trace_length_mm [ expr $fpga_to_jx1_min_trace_length_mm + $interconnect_length_mm + $jx1_to_usb_min_trace_length_mm ]
set fpga_to_usb_max_trace_length_mm [ expr $fpga_to_jx1_max_trace_length_mm + $interconnect_length_mm + $jx1_to_usb_max_trace_length_mm ]

set fpga_to_dac_min_trace_length_mm [ expr $fpga_to_jx2_min_trace_length_mm + $interconnect_length_mm + $jx2_to_dac_min_trace_length_mm ]
set fpga_to_dac_max_trace_length_mm [ expr $fpga_to_jx2_max_trace_length_mm + $interconnect_length_mm + $jx2_to_dac_max_trace_length_mm ]

set fpga_to_adc_min_trace_length_mm [ expr $fpga_to_jx2_min_trace_length_mm + $interconnect_length_mm + $jx2_to_adc_min_trace_length_mm ]
set fpga_to_adc_max_trace_length_mm [ expr $fpga_to_jx2_max_trace_length_mm + $interconnect_length_mm + $jx2_to_adc_max_trace_length_mm ]



set propagation_time_ns_per_mm 0.00564



set fpga_to_usb_max_trace_length_mismatch_mm [ expr $fpga_to_usb_max_trace_length_mm - $fpga_to_usb_min_trace_length_mm ]
set fpga_to_dac_max_trace_length_mismatch_mm [ expr $fpga_to_dac_max_trace_length_mm - $fpga_to_dac_min_trace_length_mm ]
set fpga_to_adc_max_trace_length_mismatch_mm [ expr $fpga_to_adc_max_trace_length_mm - $fpga_to_adc_min_trace_length_mm ]


set fpga_to_usb_max_trace_skew_ns [ expr $propagation_time_ns_per_mm * $fpga_to_usb_max_trace_length_mismatch_mm ]
set fpga_to_dac_max_trace_skew_ns [ expr $propagation_time_ns_per_mm * $fpga_to_dac_max_trace_length_mismatch_mm ]
set fpga_to_adc_max_trace_skew_ns [ expr $propagation_time_ns_per_mm * $fpga_to_adc_max_trace_length_mismatch_mm ]






set period_ns 10.0
set ft601_output_setup_ns 3.0
set ft601_output_hold_ns 3.5
set ft601_input_setup_ns 1.0
set ft601_input_hold_ns 4.8

set min_input_delay [ expr $ft601_output_hold_ns - $fpga_to_usb_max_trace_skew_ns ]
set max_input_delay [ expr [ expr $period_ns - $ft601_output_setup_ns ] + $fpga_to_usb_max_trace_skew_ns ]

set min_output_delay [ expr $ft601_input_hold_ns - $fpga_to_usb_max_trace_skew_ns ]
set max_output_delay [ expr [ expr $period_ns - $ft601_input_setup_ns ] + $fpga_to_usb_max_trace_skew_ns ]

set_input_delay -clock [get_clocks USB_CLK] -min $min_input_delay $timed_usb_inputs
set_input_delay -clock [get_clocks USB_CLK] -max $max_input_delay $timed_usb_inputs

set_output_delay -clock [get_clocks USB_CLK] -min $min_output_delay $timed_usb_outputs
set_output_delay -clock [get_clocks USB_CLK] -max $max_output_delay $timed_usb_outputs
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    