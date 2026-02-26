# Reset the simulation to time 0
restart -f

# Add the main signals
add wave sim:/jalr_testbench/dut/ieu/dp/*

# Add the specific signal that was failing
add wave -noupdate -decimal sim:/jalr_testbench/dut/ieu/dp/IEUAdr

# Add the register file internal array to see 'ra'
add wave sim:/jalr_testbench/dut/ieu/dp/rf/rf

# Add signals (Wildcard * adds everything in that module)
add wave -noupdate -divider "TOP SIGNALS"
add wave sim:/testbench/dut/*

# Add specific nested signals with formatting
add wave -noupdate -divider "DATAPATH"
add wave -noupdate -decimal -color "Cyan" sim:/testbench/dut/datapath/IEUAdr
add wave -noupdate -hex sim:/testbench/dut/datapath/rf/ra
add wave -noupdate -hex sim:/testbench/dut/datapath/rf/t1

# Run the simulation
run -all

# Zoom to fit the data
wave zoom full
