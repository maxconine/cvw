# Add the main signals
add wave sim:/jalr_testbench/dut/ieu/dp/*

# Add the specific signal that was failing
add wave -noupdate -decimal sim:/jalr_testbench/dut/ieu/dp/IEUAdr

# Add the register file internal array to see 'ra'
add wave sim:/jalr_testbench/dut/ieu/dp/rf/rf

run -all
