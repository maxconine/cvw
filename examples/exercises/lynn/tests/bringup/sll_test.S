// Tests for SLL (Shift Left Logical)
// Logic: rd = rs1 << rs2[4:0]
// Constraints: Only addi, beq, j, lui, li, and sll.

.extern return_sll_test
.extern fail
.section .text.init
.globl sll_test
.type sll_test, @function

sll_test:

    # -----------------------------------------------------------------
    # Test 1: Basic Shift Left
    # Logic: 1 << 4 = 16
    # -----------------------------------------------------------------
test_sll_1:
    li      t1, 1
    li      t2, 4
    sll     t3, t1, t2
    li      t4, 16
    beq     t3, t4, test_sll_2
    j       Fail_Sll_1

    # -----------------------------------------------------------------
    # Test 2: Shift Left by Zero (Identity)
    # Logic: 0xABC << 0 = 0xABC
    # -----------------------------------------------------------------
test_sll_2:
    li      t1, 0xABC
    li      t2, 0
    sll     t3, t1, t2
    li      t4, 0xABC
    beq     t3, t4, test_sll_3
    j       Fail_Sll_2

    # -----------------------------------------------------------------
    # Test 3: Shift to MSB
    # Logic: 1 << 31 = 0x80000000
    # -----------------------------------------------------------------
test_sll_3:
    li      t1, 1
    li      t2, 31
    sll     t3, t1, t2
    lui     t4, 0x80000         # 0x80000000
    beq     t3, t4, pass_sll
    j       Fail_Sll_3

pass_sll:
    j return_sll_test

# --- Failure Handlers ---
Fail_Sll_1:
    li gp, 1351
    j fail
Fail_Sll_2:
    li gp, 1352
    j fail
Fail_Sll_3:
    li gp, 1353
    j fail
