# vivado.tcl
#	ZedBoard simple build script
#	Version 1.0
# 
# Copyright (C) 2013 H.Poetzl

set ODIR .

# STEP#1: setup design sources and constraints

read_vhdl ../ps7_stub.vhd
read_vhdl ../divider.vhd
read_vhdl ../pmod_debug.vhd
read_vhdl ../cmv_pll.vhd
read_vhdl ../cmv_spi.vhd
read_vhdl ../reg_spi.vhd
read_vhdl ../top.vhd

read_xdc ../ps7_stub.xdc
read_xdc ../pmod_debug.xdc
read_xdc ../top.xdc

set_property PART xc7z020clg484-1 [current_project]
set_property BOARD em.avnet.com:zynq:zed:c [current_project]

# STEP#2: run synthesis, write checkpoint design

synth_design -top top -flatten rebuilt
write_checkpoint -force $ODIR/post_synth

# STEP#3: run placement and logic optimzation, write checkpoint design

opt_design -resynth_area
# power_opt_design
place_design
phys_opt_design
write_checkpoint -force $ODIR/post_place

# STEP#4: run router, write checkpoint design

route_design
write_checkpoint -force $ODIR/post_route

# STEP#5: generate a bitstream

write_bitstream -force $ODIR/cmv_io.bit

# STEP#6: generate reports

report_clocks

report_utilization -hierarchical -file utilization.rpt
report_clock_utilization -file utilization.rpt -append
report_datasheet -file datasheet.rpt
report_timing_summary -file timing.rpt

source ../vivado_program.tcl
