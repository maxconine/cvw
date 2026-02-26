# coremark_waves.do
# Reset the simulation and clear out any old waves
restart -f
delete wave *

# -------------------------------------------------------------------------
# 1. SYSTEM & FETCH (What instruction are we running?)
# -------------------------------------------------------------------------
add wave -noupdate -divider "FETCH"
add wave -noupdate sim:/testbench/clk
add wave -noupdate sim:/testbench/reset
add wave -noupdate -radix hexadecimal -color "Yellow" sim:/testbench/PC
add wave -noupdate -radix hexadecimal -color "Yellow" sim:/testbench/Instr

# -------------------------------------------------------------------------
# 2. CONTROL (What is the brain telling the processor to do?)
# -------------------------------------------------------------------------
add wave -noupdate -divider "CONTROL"
add wave -noupdate -radix binary sim:/testbench/dut/ieu/c/PCSrc
add wave -noupdate -radix binary sim:/testbench/dut/ieu/c/ResultSrc
add wave -noupdate -radix binary sim:/testbench/dut/ieu/c/ALUControl
add wave -noupdate -radix binary sim:/testbench/dut/ieu/c/ImmSrc
add wave -noupdate -radix binary sim:/testbench/dut/ieu/c/RegWrite

# -------------------------------------------------------------------------
# 3. REGISTER FILE (What data are we pulling / saving?)
# -------------------------------------------------------------------------
add wave -noupdate -divider "REG FILE"
# Key temporary registers usually used in assembly tests
add wave -noupdate -radix hexadecimal sim:/testbench/dut/ieu/dp/rf/rf[1]  ;# ra
add wave -noupdate -radix hexadecimal sim:/testbench/dut/ieu/dp/rf/rf[5]  ;# t0
add wave -noupdate -radix hexadecimal sim:/testbench/dut/ieu/dp/rf/rf[6]  ;# t1
add wave -noupdate -radix hexadecimal sim:/testbench/dut/ieu/dp/rf/rf[7]  ;# t2
# The final data being written back to the register file
add wave -noupdate -radix hexadecimal -color "Cyan" sim:/testbench/dut/ieu/dp/Result

# -------------------------------------------------------------------------
# 4. EXECUTE / ALU (What is the math doing?)
# -------------------------------------------------------------------------
add wave -noupdate -divider "ALU"
# Look here to verify your shifts (SLLI, SRLI) and comparisons (SLTU, SLTIU)
add wave -noupdate -radix hexadecimal sim:/testbench/dut/ieu/dp/SrcA
add wave -noupdate -radix hexadecimal sim:/testbench/dut/ieu/dp/SrcB
add wave -noupdate -radix hexadecimal -color "Orange" sim:/testbench/dut/ieu/dp/ALUResult

# -------------------------------------------------------------------------
# 5. MEMORY (Are we loading/storing?)
# -------------------------------------------------------------------------
add wave -noupdate -divider "MEMORY"
add wave -noupdate sim:/testbench/MemEn
add wave -noupdate sim:/testbench/WriteEn
add wave -noupdate -radix hexadecimal sim:/testbench/DataAdr
add wave -noupdate -radix hexadecimal sim:/testbench/WriteData
add wave -noupdate -radix hexadecimal sim:/testbench/ReadData

# Run the simulation and fit the waves to the screen
run -all
wave zoom full
