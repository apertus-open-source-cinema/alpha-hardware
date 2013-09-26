
create_clock -name clk_100 -period 10 -waveform {0 5} [get_ports clk_100]
set_property PACKAGE_PIN Y9 [get_ports clk_100]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100]

set_property PACKAGE_PIN Y16 [get_ports i2c0_sda]
set_property PACKAGE_PIN AA18 [get_ports i2c0_scl]

set_property IOSTANDARD LVCMOS33 [get_ports i2c0_*]

set_property PACKAGE_PIN U7 [get_ports i2c1_sda]
set_property PACKAGE_PIN R7 [get_ports i2c1_scl]

set_property IOSTANDARD LVCMOS33 [get_ports i2c1_*]

set_property PACKAGE_PIN V12 [get_ports spi_en]
set_property PACKAGE_PIN W11 [get_ports spi_clk]
set_property PACKAGE_PIN W10 [get_ports spi_in]
set_property PACKAGE_PIN W12 [get_ports spi_out]

set_property IOSTANDARD LVCMOS33 [get_ports spi_*]

set_property PACKAGE_PIN T22 [get_ports led[0]]
set_property PACKAGE_PIN T21 [get_ports led[1]]
set_property PACKAGE_PIN U22 [get_ports led[2]]
set_property PACKAGE_PIN U21 [get_ports led[3]]
set_property PACKAGE_PIN V22 [get_ports led[4]]
set_property PACKAGE_PIN W22 [get_ports led[5]]
set_property PACKAGE_PIN U19 [get_ports led[6]]
set_property PACKAGE_PIN U14 [get_ports led[7]]

set_property IOSTANDARD LVCMOS33 [get_ports led]

set_property PACKAGE_PIN W8 [get_ports cmv_clk]
set_property PACKAGE_PIN V10 [get_ports cmv_t_exp1]
set_property PACKAGE_PIN V9 [get_ports cmv_t_exp2]
set_property PACKAGE_PIN V8 [get_ports cmv_frame_req]

set_property IOSTANDARD LVCMOS33 [get_ports cmv_*]



set_property PACKAGE_PIN L19 [get_ports cmv_lvds_clk_n]
set_property PACKAGE_PIN L18 [get_ports cmv_lvds_clk_p]

set_property PACKAGE_PIN C19 [get_ports cmv_lvds_outclk_n]
set_property PACKAGE_PIN D18 [get_ports cmv_lvds_outclk_p]

set_property IOSTANDARD LVDS_25 [get_ports cmv_lvds_*]
