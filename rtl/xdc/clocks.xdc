

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





set timed_usb_signals [list \
    [get_ports "USB_D[*]"] \
    [get_ports "USB_BE[*]"] \
    [get_ports "USB_TXE_N"] \
    [get_ports "USB_RXF_N"] \
    [get_ports "USB_RD_N"] \
    [get_ports "USB_WR_N"]


#set_output_delay -clock USB_CLK -clock_fall -max 7 -min 3 $timed_usb_signals;




set_input_delay -clock [get_clocks USB_CLK] -min -add_delay 2.700 $timed_usb_signals
set_input_delay -clock [get_clocks USB_CLK] -max -add_delay 3.800 $timed_usb_signals
set_output_delay -clock [get_clocks USB_CLK] -min -add_delay -5.100 $timed_usb_signals
set_output_delay -clock [get_clocks USB_CLK] -max -add_delay 1.300 $timed_usb_signals


    
    
    
    