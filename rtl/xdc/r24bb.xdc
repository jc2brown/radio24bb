set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

connect_debug_port u_ila_1/probe6 [get_nets [list {ft601_mcfifo_if_inst/can_read[1]_16}]]
connect_debug_port u_ila_1/probe7 [get_nets [list {ft601_mcfifo_if_inst/can_read[2]_15}]]
connect_debug_port u_ila_1/probe8 [get_nets [list {ft601_mcfifo_if_inst/can_read[3]_14}]]
connect_debug_port u_ila_1/probe9 [get_nets [list {ft601_mcfifo_if_inst/can_read[4]_13}]]
connect_debug_port u_ila_1/probe10 [get_nets [list {ft601_mcfifo_if_inst/can_write[1]_3}]]
connect_debug_port u_ila_1/probe11 [get_nets [list {ft601_mcfifo_if_inst/can_write[2]_2}]]
connect_debug_port u_ila_1/probe12 [get_nets [list {ft601_mcfifo_if_inst/can_write[3]_1}]]
connect_debug_port u_ila_1/probe13 [get_nets [list {ft601_mcfifo_if_inst/can_write[4]_0}]]






connect_debug_port u_ila_0/clk [get_nets [list clk0_mmcm]]


create_generated_clock -name ADC_CLK_N -source [get_pins max19506_if_inst/clkout_n_oddr_inst/C] -divide_by 1 -invert [get_ports ADC_CLK_N]
create_generated_clock -name ADC_CLK_P -source [get_pins max19506_if_inst/clkout_p_oddr_inst/C] -divide_by 1 [get_ports ADC_CLK_P]
create_generated_clock -name DAC_CLK -source [get_pins max5851_if_inst/clkin_oddr_inst/C] -divide_by 1 [get_ports DAC_CLK]
create_generated_clock -name DAC_CLKX_N -source [get_pins max5851_if_inst/clk_n_oddr_inst/C] -divide_by 1 -invert [get_ports DAC_CLKX_N]
create_generated_clock -name DAC_CLKX_P -source [get_pins max5851_if_inst/clk_p_oddr_inst/C] -divide_by 1 [get_ports DAC_CLKX_P]
connect_debug_port u_ila_0/clk [get_nets [list u_ila_0_clk0_mmcm_BUFG]]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 3 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list ft601_mcfifo_if_inst/clk0_mmcm_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {ft601_mcfifo_if_inst/wr_ch_rd_data[1][0]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][1]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][2]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][3]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][4]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][5]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][6]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][7]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][8]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][9]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][10]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][11]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][12]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][13]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][14]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][15]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][16]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][17]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][18]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][19]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][20]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][21]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][22]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][23]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][24]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][25]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][26]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][27]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][28]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][29]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][30]} {ft601_mcfifo_if_inst/wr_ch_rd_data[1][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {ft601_mcfifo_if_inst/data_oe_n[0]} {ft601_mcfifo_if_inst/data_oe_n[1]} {ft601_mcfifo_if_inst/data_oe_n[2]} {ft601_mcfifo_if_inst/data_oe_n[3]} {ft601_mcfifo_if_inst/data_oe_n[4]} {ft601_mcfifo_if_inst/data_oe_n[5]} {ft601_mcfifo_if_inst/data_oe_n[6]} {ft601_mcfifo_if_inst/data_oe_n[7]} {ft601_mcfifo_if_inst/data_oe_n[8]} {ft601_mcfifo_if_inst/data_oe_n[9]} {ft601_mcfifo_if_inst/data_oe_n[10]} {ft601_mcfifo_if_inst/data_oe_n[11]} {ft601_mcfifo_if_inst/data_oe_n[12]} {ft601_mcfifo_if_inst/data_oe_n[13]} {ft601_mcfifo_if_inst/data_oe_n[14]} {ft601_mcfifo_if_inst/data_oe_n[15]} {ft601_mcfifo_if_inst/data_oe_n[16]} {ft601_mcfifo_if_inst/data_oe_n[17]} {ft601_mcfifo_if_inst/data_oe_n[18]} {ft601_mcfifo_if_inst/data_oe_n[19]} {ft601_mcfifo_if_inst/data_oe_n[20]} {ft601_mcfifo_if_inst/data_oe_n[21]} {ft601_mcfifo_if_inst/data_oe_n[22]} {ft601_mcfifo_if_inst/data_oe_n[23]} {ft601_mcfifo_if_inst/data_oe_n[24]} {ft601_mcfifo_if_inst/data_oe_n[25]} {ft601_mcfifo_if_inst/data_oe_n[26]} {ft601_mcfifo_if_inst/data_oe_n[27]} {ft601_mcfifo_if_inst/data_oe_n[28]} {ft601_mcfifo_if_inst/data_oe_n[29]} {ft601_mcfifo_if_inst/data_oe_n[30]} {ft601_mcfifo_if_inst/data_oe_n[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 32 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {ft601_mcfifo_if_inst/data_out[0]} {ft601_mcfifo_if_inst/data_out[1]} {ft601_mcfifo_if_inst/data_out[2]} {ft601_mcfifo_if_inst/data_out[3]} {ft601_mcfifo_if_inst/data_out[4]} {ft601_mcfifo_if_inst/data_out[5]} {ft601_mcfifo_if_inst/data_out[6]} {ft601_mcfifo_if_inst/data_out[7]} {ft601_mcfifo_if_inst/data_out[8]} {ft601_mcfifo_if_inst/data_out[9]} {ft601_mcfifo_if_inst/data_out[10]} {ft601_mcfifo_if_inst/data_out[11]} {ft601_mcfifo_if_inst/data_out[12]} {ft601_mcfifo_if_inst/data_out[13]} {ft601_mcfifo_if_inst/data_out[14]} {ft601_mcfifo_if_inst/data_out[15]} {ft601_mcfifo_if_inst/data_out[16]} {ft601_mcfifo_if_inst/data_out[17]} {ft601_mcfifo_if_inst/data_out[18]} {ft601_mcfifo_if_inst/data_out[19]} {ft601_mcfifo_if_inst/data_out[20]} {ft601_mcfifo_if_inst/data_out[21]} {ft601_mcfifo_if_inst/data_out[22]} {ft601_mcfifo_if_inst/data_out[23]} {ft601_mcfifo_if_inst/data_out[24]} {ft601_mcfifo_if_inst/data_out[25]} {ft601_mcfifo_if_inst/data_out[26]} {ft601_mcfifo_if_inst/data_out[27]} {ft601_mcfifo_if_inst/data_out[28]} {ft601_mcfifo_if_inst/data_out[29]} {ft601_mcfifo_if_inst/data_out[30]} {ft601_mcfifo_if_inst/data_out[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 4 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {ft601_mcfifo_if_inst/wr_ch_rd_be[1][0]} {ft601_mcfifo_if_inst/wr_ch_rd_be[1][1]} {ft601_mcfifo_if_inst/wr_ch_rd_be[1][2]} {ft601_mcfifo_if_inst/wr_ch_rd_be[1][3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 4 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {ft601_mcfifo_if_inst/state[0]} {ft601_mcfifo_if_inst/state[1]} {ft601_mcfifo_if_inst/state[2]} {ft601_mcfifo_if_inst/state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 4 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {ft601_mcfifo_if_inst/be_oe_n[0]} {ft601_mcfifo_if_inst/be_oe_n[1]} {ft601_mcfifo_if_inst/be_oe_n[2]} {ft601_mcfifo_if_inst/be_oe_n[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 4 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {ft601_mcfifo_if_inst/cmd_be[0]} {ft601_mcfifo_if_inst/cmd_be[1]} {ft601_mcfifo_if_inst/cmd_be[2]} {ft601_mcfifo_if_inst/cmd_be[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 32 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {ft601_mcfifo_if_inst/cmd_data[0]} {ft601_mcfifo_if_inst/cmd_data[1]} {ft601_mcfifo_if_inst/cmd_data[2]} {ft601_mcfifo_if_inst/cmd_data[3]} {ft601_mcfifo_if_inst/cmd_data[4]} {ft601_mcfifo_if_inst/cmd_data[5]} {ft601_mcfifo_if_inst/cmd_data[6]} {ft601_mcfifo_if_inst/cmd_data[7]} {ft601_mcfifo_if_inst/cmd_data[8]} {ft601_mcfifo_if_inst/cmd_data[9]} {ft601_mcfifo_if_inst/cmd_data[10]} {ft601_mcfifo_if_inst/cmd_data[11]} {ft601_mcfifo_if_inst/cmd_data[12]} {ft601_mcfifo_if_inst/cmd_data[13]} {ft601_mcfifo_if_inst/cmd_data[14]} {ft601_mcfifo_if_inst/cmd_data[15]} {ft601_mcfifo_if_inst/cmd_data[16]} {ft601_mcfifo_if_inst/cmd_data[17]} {ft601_mcfifo_if_inst/cmd_data[18]} {ft601_mcfifo_if_inst/cmd_data[19]} {ft601_mcfifo_if_inst/cmd_data[20]} {ft601_mcfifo_if_inst/cmd_data[21]} {ft601_mcfifo_if_inst/cmd_data[22]} {ft601_mcfifo_if_inst/cmd_data[23]} {ft601_mcfifo_if_inst/cmd_data[24]} {ft601_mcfifo_if_inst/cmd_data[25]} {ft601_mcfifo_if_inst/cmd_data[26]} {ft601_mcfifo_if_inst/cmd_data[27]} {ft601_mcfifo_if_inst/cmd_data[28]} {ft601_mcfifo_if_inst/cmd_data[29]} {ft601_mcfifo_if_inst/cmd_data[30]} {ft601_mcfifo_if_inst/cmd_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 4 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {ft601_mcfifo_if_inst/be_out[0]} {ft601_mcfifo_if_inst/be_out[1]} {ft601_mcfifo_if_inst/be_out[2]} {ft601_mcfifo_if_inst/be_out[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 3 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {ft601_mcfifo_if_inst/channel[0]} {ft601_mcfifo_if_inst/channel[1]} {ft601_mcfifo_if_inst/channel[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 32 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {ft601_mcfifo_if_inst/data_in[0]} {ft601_mcfifo_if_inst/data_in[1]} {ft601_mcfifo_if_inst/data_in[2]} {ft601_mcfifo_if_inst/data_in[3]} {ft601_mcfifo_if_inst/data_in[4]} {ft601_mcfifo_if_inst/data_in[5]} {ft601_mcfifo_if_inst/data_in[6]} {ft601_mcfifo_if_inst/data_in[7]} {ft601_mcfifo_if_inst/data_in[8]} {ft601_mcfifo_if_inst/data_in[9]} {ft601_mcfifo_if_inst/data_in[10]} {ft601_mcfifo_if_inst/data_in[11]} {ft601_mcfifo_if_inst/data_in[12]} {ft601_mcfifo_if_inst/data_in[13]} {ft601_mcfifo_if_inst/data_in[14]} {ft601_mcfifo_if_inst/data_in[15]} {ft601_mcfifo_if_inst/data_in[16]} {ft601_mcfifo_if_inst/data_in[17]} {ft601_mcfifo_if_inst/data_in[18]} {ft601_mcfifo_if_inst/data_in[19]} {ft601_mcfifo_if_inst/data_in[20]} {ft601_mcfifo_if_inst/data_in[21]} {ft601_mcfifo_if_inst/data_in[22]} {ft601_mcfifo_if_inst/data_in[23]} {ft601_mcfifo_if_inst/data_in[24]} {ft601_mcfifo_if_inst/data_in[25]} {ft601_mcfifo_if_inst/data_in[26]} {ft601_mcfifo_if_inst/data_in[27]} {ft601_mcfifo_if_inst/data_in[28]} {ft601_mcfifo_if_inst/data_in[29]} {ft601_mcfifo_if_inst/data_in[30]} {ft601_mcfifo_if_inst/data_in[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 4 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {ft601_mcfifo_if_inst/be_in[0]} {ft601_mcfifo_if_inst/be_in[1]} {ft601_mcfifo_if_inst/be_in[2]} {ft601_mcfifo_if_inst/be_in[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 16 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[0]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[1]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[2]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[3]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[4]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[5]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[6]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[7]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[8]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[9]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[10]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[11]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[12]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[13]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[14]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_size[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[0]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[1]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[2]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[3]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[4]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[5]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[6]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[7]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[8]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[9]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[10]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[11]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[12]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[13]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[14]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[15]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[16]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[17]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[18]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[19]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[20]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[21]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[22]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[23]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[24]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[25]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[26]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[27]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[28]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[29]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[30]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 32 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[0]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[1]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[2]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[3]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[4]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[5]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[6]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[7]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[8]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[9]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[10]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[11]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[12]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[13]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[14]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[15]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[16]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[17]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[18]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[19]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[20]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[21]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[22]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[23]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[24]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[25]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[26]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[27]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[28]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[29]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[30]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 16 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[0]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[1]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[2]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[3]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[4]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[5]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[6]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[7]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[8]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[9]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[10]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[11]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[12]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[13]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[14]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_count[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 4 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_be[0]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_be[1]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_be[2]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_be[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 4 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/rd_be[0]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_be[1]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_be[2]} {ft601_mcfifo_if_inst/wr_buf[1]/rd_be[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {ft601_mcfifo_if_inst/can_read[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {ft601_mcfifo_if_inst/can_write[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list ft601_mcfifo_if_inst/cmd_mux]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list ft601_mcfifo_if_inst/ft601_rxf_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list ft601_mcfifo_if_inst/ft601_txe_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list ft601_mcfifo_if_inst/ft601_wr_n]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/rd_en}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/rd_valid}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_almost_done}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_done}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_req}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/rd_xfer_req_int}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list {ft601_mcfifo_if_inst/wr_ch_rd_en[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list {ft601_mcfifo_if_inst/wr_ch_rd_valid[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list {ft601_mcfifo_if_inst/wr_ch_rd_xfer_almost_done[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list {ft601_mcfifo_if_inst/wr_ch_rd_xfer_done[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list {ft601_mcfifo_if_inst/wr_ch_rd_xfer_req[1]}]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 3 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list r24bb_bd_inst/processing_system7_0/inst/FCLK_CLK0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 16 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[0]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[1]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[2]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[3]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[4]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[5]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[6]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[7]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[8]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[9]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[10]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[11]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[12]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[13]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[14]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_size[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 3 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/state[0]} {ft601_mcfifo_if_inst/wr_buf[1]/state[1]} {ft601_mcfifo_if_inst/wr_buf[1]/state[2]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 16 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[0]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[1]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[2]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[3]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[4]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[5]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[6]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[7]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[8]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[9]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[10]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[11]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[12]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[13]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[14]} {ft601_mcfifo_if_inst/wr_buf[1]/wr_data_count[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
set_property port_width 1 [get_debug_ports u_ila_1/probe3]
connect_debug_port u_ila_1/probe3 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/ack_push_pending}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
set_property port_width 1 [get_debug_ports u_ila_1/probe4]
connect_debug_port u_ila_1/probe4 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/has_full_packet}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe5]
set_property port_width 1 [get_debug_ports u_ila_1/probe5]
connect_debug_port u_ila_1/probe5 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/push_pending}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe6]
set_property port_width 1 [get_debug_ports u_ila_1/probe6]
connect_debug_port u_ila_1/probe6 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_almost_full}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe7]
set_property port_width 1 [get_debug_ports u_ila_1/probe7]
connect_debug_port u_ila_1/probe7 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_en}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe8]
set_property port_width 1 [get_debug_ports u_ila_1/probe8]
connect_debug_port u_ila_1/probe8 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_full}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe9]
set_property port_width 1 [get_debug_ports u_ila_1/probe9]
connect_debug_port u_ila_1/probe9 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_has_packet_space}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe10]
set_property port_width 1 [get_debug_ports u_ila_1/probe10]
connect_debug_port u_ila_1/probe10 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_push}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe11]
set_property port_width 1 [get_debug_ports u_ila_1/probe11]
connect_debug_port u_ila_1/probe11 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_active}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe12]
set_property port_width 1 [get_debug_ports u_ila_1/probe12]
connect_debug_port u_ila_1/probe12 [get_nets [list {ft601_mcfifo_if_inst/wr_buf[1]/wr_xfer_done}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
