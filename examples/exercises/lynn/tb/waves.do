# coremark_waves.do
add wave sim:/testbench/dut/*
add wave -noupdate -decimal sim:/testbench/dut/datapath/IEUAdr
run -all
view wave
